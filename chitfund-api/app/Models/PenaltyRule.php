<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PenaltyRule extends Model
{
    protected $fillable = ['provider_id', 'grace_days', 'flat_penalty', 'pct_penalty'];

    protected $casts = ['flat_penalty' => 'float', 'pct_penalty' => 'float'];

    public function provider() { return $this->belongsTo(User::class, 'provider_id'); }
}
