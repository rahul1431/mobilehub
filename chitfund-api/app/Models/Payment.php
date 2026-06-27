<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = ['cycle_id', 'member_id', 'group_id', 'amount', 'payment_method', 'razorpay_order_id', 'razorpay_payment_id', 'status', 'penalty_amount', 'notes', 'paid_at'];
    protected $casts = ['paid_at' => 'datetime', 'amount' => 'float', 'penalty_amount' => 'float'];

    public function cycle()  { return $this->belongsTo(Cycle::class); }
    public function member() { return $this->belongsTo(User::class, 'member_id'); }
    public function group()  { return $this->belongsTo(ChitGroup::class); }
}
