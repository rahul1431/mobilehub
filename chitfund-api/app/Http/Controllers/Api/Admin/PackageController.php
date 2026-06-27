<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ChitPackage;
use Illuminate\Http\Request;

class PackageController extends Controller
{
    public function index()
    {
        return response()->json(['success' => true, 'data' => ChitPackage::latest()->get()]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name'             => 'required|string|max:100',
            'monthly_amount'   => 'required|numeric|min:100',
            'duration_months'  => 'required|integer|min:2|max:120',
            'max_members'      => 'required|integer|min:2|max:500',
            'commission_pct'   => 'required|numeric|min:0|max:30',
            'description'      => 'nullable|string',
        ]);

        $pkg = ChitPackage::create(array_merge($data, ['created_by' => $request->user()->id]));
        return response()->json(['success' => true, 'data' => $pkg], 201);
    }

    public function show(ChitPackage $package)
    {
        return response()->json(['success' => true, 'data' => $package->load('groups')]);
    }

    public function update(Request $request, ChitPackage $package)
    {
        $data = $request->validate([
            'name'           => 'sometimes|string|max:100',
            'monthly_amount' => 'sometimes|numeric|min:100',
            'commission_pct' => 'sometimes|numeric|min:0|max:30',
            'description'    => 'nullable|string',
            'is_active'      => 'sometimes|boolean',
        ]);

        $package->update($data);
        return response()->json(['success' => true, 'data' => $package]);
    }

    public function destroy(ChitPackage $package)
    {
        if ($package->groups()->whereIn('status', ['forming', 'active'])->exists()) {
            return response()->json(['success' => false, 'message' => 'Cannot delete a package with active groups.'], 422);
        }
        $package->delete();
        return response()->json(['success' => true, 'message' => 'Package deleted.']);
    }
}
