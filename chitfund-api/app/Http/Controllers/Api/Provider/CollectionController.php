<?php
namespace App\Http\Controllers\Api\Provider;

use App\Http\Controllers\Controller;
use App\Jobs\SendNotificationJob;
use App\Models\Payment;
use Illuminate\Http\Request;

class CollectionController extends Controller
{
    public function index(Request $request)
    {
        $payments = Payment::whereHas('group', fn($q) => $q->where('provider_id', $request->user()->id))
            ->with(['member', 'cycle', 'group'])
            ->latest()
            ->paginate(30);

        return response()->json(['success' => true, 'data' => $payments]);
    }

    // Manual cash/bank transfer recording
    public function record(Request $request)
    {
        $data = $request->validate([
            'payment_id'     => 'required|exists:payments,id',
            'payment_method' => 'required|in:cash,bank_transfer',
            'notes'          => 'nullable|string|max:255',
        ]);

        $payment = Payment::findOrFail($data['payment_id']);

        if ($payment->group->provider_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $payment->update([
            'status'         => 'paid',
            'payment_method' => $data['payment_method'],
            'notes'          => $data['notes'] ?? null,
            'paid_at'        => now(),
        ]);

        SendNotificationJob::dispatch($payment->member_id, 'payment_received', [
            'title' => 'Payment Recorded',
            'body'  => "₹{$payment->amount} payment recorded for {$payment->group->name}.",
            'sms'   => "Apna Saving: ₹{$payment->amount} payment recorded for {$payment->group->name} via {$data['payment_method']}.",
        ]);

        return response()->json(['success' => true, 'data' => $payment]);
    }
}
