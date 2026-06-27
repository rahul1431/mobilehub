<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Agreement extends Model
{
    protected $fillable = ['group_id', 'member_id', 'digio_doc_id', 'pdf_storage_path', 'signed_at'];

    protected $casts = ['signed_at' => 'datetime'];

    public function group()  { return $this->belongsTo(ChitGroup::class, 'group_id'); }
    public function member() { return $this->belongsTo(User::class, 'member_id'); }
}
