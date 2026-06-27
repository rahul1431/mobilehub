<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KycDocument extends Model
{
    protected $fillable = ['member_id', 'doc_type', 'storage_path', 'digio_request_id', 'verified', 'verified_at'];
    protected $casts = ['verified' => 'boolean', 'verified_at' => 'datetime'];

    public function member() { return $this->belongsTo(User::class, 'member_id'); }
}
