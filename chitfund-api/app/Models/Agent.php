<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Agent extends Model
{
    protected $fillable = ['user_id', 'provider_id', 'commission_pct', 'total_earned'];

    protected $casts = ['commission_pct' => 'float', 'total_earned' => 'float'];

    public function user()     { return $this->belongsTo(User::class); }
    public function provider() { return $this->belongsTo(User::class, 'provider_id'); }
}
