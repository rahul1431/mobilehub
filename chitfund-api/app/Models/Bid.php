<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Bid extends Model
{
    protected $fillable = ['cycle_id', 'member_id', 'bid_amount', 'is_winning'];
    protected $casts = ['bid_amount' => 'float', 'is_winning' => 'boolean'];

    public function cycle()  { return $this->belongsTo(Cycle::class); }
    public function member() { return $this->belongsTo(User::class, 'member_id'); }
}
