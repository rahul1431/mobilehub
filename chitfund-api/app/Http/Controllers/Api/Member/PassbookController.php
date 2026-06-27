<?php
namespace App\Http\Controllers\Api\Member;

use App\Http\Controllers\Controller;
use App\Jobs\GenerateReportJob;
use App\Models\Dividend;
use App\Models\Payment;
use Illuminate\Http\Request;

class PassbookController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $payments = Payment::where('member_id', $userId)
            ->with(['group', 'cycle'])
            ->get()
            ->map(fn($p) => [
                'type'       => 'payment',
                'date'       => $p->paid_at ?? $p->created_at,
                'amount'     => -$p->amount,
                'label'      => "Chit Payment - {$p->group->name} (Cycle #{$p->cycle->cycle_number})",
                'status'     => $p->status,
                'penalty'    => $p->penalty_amount,
            ]);

        $dividends = Dividend::where('member_id', $userId)
            ->with(['cycle.group'])
            ->get()
            ->map(fn($d) => [
                'type'   => 'dividend',
                'date'   => $d->disbursed_at ?? $d->created_at,
                'amount' => +$d->amount,
                'label'  => "Dividend - {$d->cycle->group->name} (Cycle #{$d->cycle->cycle_number})",
                'status' => $d->status,
            ]);

        $ledger = $payments->concat($dividends)->sortByDesc('date')->values();

        return response()->json([
            'success' => true,
            'data'    => $ledger,
            'summary' => [
                'total_paid'     => Payment::where('member_id', $userId)->where('status', 'paid')->sum('amount'),
                'total_received' => Dividend::where('member_id', $userId)->where('status', 'disbursed')->sum('amount'),
            ],
        ]);
    }

    public function exportPdf(Request $request)
    {
        $userId = $request->user()->id;
        GenerateReportJob::dispatch('passbook', $userId, $userId);

        return response()->json([
            'success' => true,
            'message' => 'Your passbook PDF is being generated. You will receive a notification when it\'s ready.',
        ]);
    }
}
