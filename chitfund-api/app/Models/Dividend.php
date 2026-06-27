<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Dividend extends Model
{
    protected $fillable = ['cycle_id', 'member_id', 'amount', 'status', 'disbursed_at'];
    protected $casts = ['amount' => 'float', 'disbursed_at' => 'datetime'];

    public function cycle()  { return $this->belongsTo(Cycle::class); }
    public function member() { return $this->belongsTo(User::class, 'member_id'); }
}
