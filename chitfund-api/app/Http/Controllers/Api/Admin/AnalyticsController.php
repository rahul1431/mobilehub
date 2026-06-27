<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ChitGroup;
use App\Models\ChitPackage;
use App\Models\Payment;
use App\Models\SubscriptionPlan;
use App\Models\User;

class AnalyticsController extends Controller
{
    public function index()
    {
        // Monthly AUM = sum of all active group monthly amounts
        $monthlyAum = ChitGroup::whereIn('status', ['forming', 'active'])
            ->join('chit_packages', 'chit_groups.package_id', '=', 'chit_packages.id')
            ->sum('chit_packages.monthly_amount');

        $plans = SubscriptionPlan::withCount(['subscriptions as subscribers' => function ($q) {
            $q->where('status', 'active');
        }])->get()->map(fn($p) => [
            'name'        => $p->name,
            'price'       => $p->price,
            'subscribers' => $p->subscribers,
        ]);

        return response()->json([
            'success' => true,
            'data'    => [
                'total_providers'            => User::where('role', 'chit_provider')->count(),
                'total_members'              => User::where('role', 'chit_member')->count(),
                'active_groups'              => ChitGroup::whereIn('status', ['forming', 'active'])->count(),
                'completed_groups'           => ChitGroup::where('status', 'completed')->count(),
                'monthly_aum'                => (float) $monthlyAum,
                'total_collected_this_month' => (float) Payment::where('status', 'paid')
                    ->whereMonth('paid_at', now()->month)
                    ->sum('amount'),
                'total_collected_all_time'   => (float) Payment::where('status', 'paid')->sum('amount'),
                'plans'                      => $plans,
            ],
        ]);
    }
}
