<?php
namespace App\Jobs;

use App\Models\ChitGroup;
use App\Models\Cycle;
use App\Models\Payment;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class GenerateReportJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 2;

    // $type: 'passbook' | 'group_register' | 'provider_summary'
    public function __construct(
        private string $type,
        private int    $subjectId,   // user_id for passbook, group_id for register
        private int    $requestedBy,
    ) {}

    public function handle(): void
    {
        try {
            $pdf  = match ($this->type) {
                'passbook'         => $this->generatePassbook(),
                'group_register'   => $this->generateGroupRegister(),
                'provider_summary' => $this->generateProviderSummary(),
                default            => throw new \InvalidArgumentException("Unknown report type: {$this->type}"),
            };

            $path = "reports/{$this->type}_{$this->subjectId}_" . now()->format('Ymd_His') . '.pdf';
            Storage::put($path, $pdf->output());

            Log::info("Report generated: {$path}");

            // Notify requester
            SendNotificationJob::dispatch($this->requestedBy, 'report_ready', [
                'title' => 'Report Ready',
                'body'  => 'Your ' . str_replace('_', ' ', $this->type) . ' report has been generated.',
                'sms'   => 'Apna Saving: Your report is ready. Open the app to download it.',
            ], ['push']);
        } catch (\Throwable $e) {
            Log::error("GenerateReportJob failed [{$this->type}#{$this->subjectId}]: " . $e->getMessage());
            $this->fail($e);
        }
    }

    private function generatePassbook(): \Barryvdh\DomPDF\PDF
    {
        $member   = User::findOrFail($this->subjectId);
        $payments = Payment::where('member_id', $this->subjectId)
            ->with('group', 'cycle')
            ->orderBy('paid_at', 'desc')
            ->get();

        return Pdf::loadView('reports.passbook', compact('member', 'payments'));
    }

    private function generateGroupRegister(): \Barryvdh\DomPDF\PDF
    {
        $group = ChitGroup::with(['memberships.member', 'cycles.payments', 'provider', 'package'])
            ->findOrFail($this->subjectId);

        return Pdf::loadView('reports.group_register', compact('group'));
    }

    private function generateProviderSummary(): \Barryvdh\DomPDF\PDF
    {
        $provider = User::with(['providerGroups.package', 'providerGroups.memberships'])->findOrFail($this->subjectId);
        $groups   = $provider->providerGroups()->with('package', 'memberships')->get();

        $totalCollected = Payment::whereIn('group_id', $groups->pluck('id'))
            ->where('status', 'paid')
            ->sum('amount');

        return Pdf::loadView('reports.provider_summary', compact('provider', 'groups', 'totalCollected'));
    }
}
