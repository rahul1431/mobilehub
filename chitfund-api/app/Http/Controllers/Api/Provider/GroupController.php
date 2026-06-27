<?php
namespace App\Http\Controllers\Api\Provider;

use App\Http\Controllers\Controller;
use App\Models\ChitGroup;
use Illuminate\Http\Request;

class GroupController extends Controller
{
    public function index(Request $request)
    {
        $groups = ChitGroup::where('provider_id', $request->user()->id)
            ->with('package')
            ->withCount('memberships')
            ->latest()
            ->get();

        return response()->json(['success' => true, 'data' => $groups]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'package_id' => 'required|exists:chit_packages,id',
            'name'       => 'required|string|max:150',
            'start_date' => 'nullable|date|after_or_equal:today',
        ]);

        if (!$request->user()->canCreateGroup()) {
            return response()->json(['success' => false, 'message' => 'Group limit reached for your subscription plan.'], 403);
        }

        $package = \App\Models\ChitPackage::findOrFail($data['package_id']);

        $group = ChitGroup::create([
            'package_id'    => $data['package_id'],
            'provider_id'   => $request->user()->id,
            'name'          => $data['name'],
            'start_date'    => $data['start_date'] ?? null,
            'total_members' => $package->max_members,
            'status'        => 'forming',
        ]);

        return response()->json(['success' => true, 'data' => $group->load('package')], 201);
    }

    public function show(ChitGroup $group)
    {
        $this->authorize('view', $group);
        $group->load(['package', 'memberships.member', 'cycles']);
        return response()->json(['success' => true, 'data' => $group]);
    }

    public function update(Request $request, ChitGroup $group)
    {
        $this->authorize('update', $group);
        $group->update($request->only(['name', 'start_date']));
        return response()->json(['success' => true, 'data' => $group]);
    }

    public function destroy(ChitGroup $group)
    {
        $this->authorize('delete', $group);
        if ($group->status === 'active') {
            return response()->json(['success' => false, 'message' => 'Cannot delete an active group.'], 422);
        }
        $group->delete();
        return response()->json(['success' => true, 'message' => 'Group deleted.']);
    }

    // Member route: GET /api/member/groups
    public function myGroups(Request $request)
    {
        $groups = ChitGroup::whereHas('memberships', fn($q) => $q->where('member_id', $request->user()->id)->where('is_active', true))
            ->with(['package', 'provider'])
            ->get();

        return response()->json(['success' => true, 'data' => $groups]);
    }

    public function showMemberView(Request $request, ChitGroup $group)
    {
        $membership = $group->memberships()->where('member_id', $request->user()->id)->firstOrFail();
        $group->load(['package', 'provider', 'cycles' => fn($q) => $q->latest()->limit(5)]);
        return response()->json(['success' => true, 'data' => $group, 'membership' => $membership]);
    }
}
