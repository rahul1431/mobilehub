<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cycle extends Model
{
    protected $fillable = ['group_id', 'cycle_number', 'due_date', 'total_pot', 'winning_bid', 'winner_id', 'dividend_per_member', 'cycle_method', 'status', 'closed_at'];
    protected $casts = ['due_date' => 'date', 'closed_at' => 'datetime', 'total_pot' => 'float', 'winning_bid' => 'float'];

    public function group()    { return $this->belongsTo(ChitGroup::class); }
    public function winner()   { return $this->belongsTo(User::class, 'winner_id'); }
    public function payments() { return $this->hasMany(Payment::class); }
    public function bids()     { return $this->hasMany(Bid::class); }
    public function dividends(){ return $this->hasMany(Dividend::class); }
}
