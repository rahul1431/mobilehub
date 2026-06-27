<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ChitGroup;
use App\Models\Payment;
use App\Models\User;

class AnalyticsController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'data'    => [
                'total_providers'     => User::where('role', 'chit_provider')->count(),
                'total_members'       => User::where('role', 'chit_member')->count(),
                'active_groups'       => ChitGroup::whereIn('status', ['forming', 'active'])->count(),
                'completed_groups'    => ChitGroup::where('status', 'completed')->count(),
                'total_collected_this_month' => Payment::where('status', 'paid')
                    ->whereMonth('paid_at', now()->month)
                    ->sum('amount'),
                'total_collected_all_time' => Payment::where('status', 'paid')->sum('amount'),
            ],
        ]);
    }
}
