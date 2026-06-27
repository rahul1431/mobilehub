<?php
namespace App\Http\Controllers\Api\Member;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Services\RazorpayService;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function index(Request $request)
    {
        $payments = Payment::where('member_id', $request->user()->id)
            ->with(['cycle', 'group'])
            ->latest()
            ->paginate(30);

        return response()->json(['success' => true, 'data' => $payments]);
    }

    public function createOrder(Request $request, RazorpayService $razorpay)
    {
        $request->validate(['payment_id' => 'required|exists:payments,id']);

        $payment = Payment::findOrFail($request->payment_id);
        if ($payment->member_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $totalAmount = $payment->amount + $payment->penalty_amount;
        $order = $razorpay->createOrder($totalAmount, 'pay_' . $payment->id, [
            'group'  => $payment->group->name,
            'member' => $request->user()->phone,
        ]);

        $payment->update(['razorpay_order_id' => $order['order_id']]);

        return response()->json(['success' => true, 'data' => $order]);
    }

    // Called after Razorpay success on client side (backup to webhook)
    public function confirm(Request $request, RazorpayService $razorpay)
    {
        $request->validate([
            'razorpay_order_id'   => 'required|string',
            'razorpay_payment_id' => 'required|string',
            'razorpay_signature'  => 'required|string',
        ]);

        $verified = $razorpay->verifyPaymentSignature(
            $request->razorpay_order_id,
            $request->razorpay_payment_id,
            $request->razorpay_signature
        );

        if (!$verified) {
            return response()->json(['success' => false, 'message' => 'Payment verification failed.'], 422);
        }

        $payment = Payment::where('razorpay_order_id', $request->razorpay_order_id)->firstOrFail();
        $payment->update([
            'razorpay_payment_id' => $request->razorpay_payment_id,
            'status'              => 'paid',
            'payment_method'      => 'razorpay',
            'paid_at'             => now(),
        ]);

        return response()->json(['success' => true, 'message' => 'Payment confirmed.']);
    }
}
