<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
  body  { font-family: DejaVu Sans, sans-serif; font-size: 11px; color: #1a1a2e; }
  .hdr  { background: #6C63FF; color: #fff; padding: 18px 24px; }
  .hdr h1 { margin: 0; font-size: 18px; }
  .hdr p  { margin: 4px 0 0; font-size: 10px; opacity: 0.85; }
  .summary { padding: 16px 24px; display: flex; flex-wrap: wrap; gap: 24px; background: #f7f6ff; }
  .kv { display: inline-block; }
  .kv .l { font-size: 9px; color: #999; text-transform: uppercase; }
  .kv .v { font-weight: bold; font-size: 14px; }
  .sec  { padding: 14px 24px; }
  h2    { font-size: 13px; color: #6C63FF; margin: 0 0 8px; }
  table { width: 100%; border-collapse: collapse; }
  th    { background: #f0eeff; color: #6C63FF; font-size: 9px; padding: 7px 8px; text-align: left; border-bottom: 2px solid #6C63FF; }
  td    { padding: 7px 8px; border-bottom: 1px solid #eee; font-size: 10px; }
</style>
</head>
<body>
<div class="hdr">
  <h1>Provider Summary — Apna Saving</h1>
  <p>{{ $provider->full_name ?? $provider->phone }} &nbsp;|&nbsp; Report Date: {{ now()->format('d M Y') }}</p>
</div>

<div class="summary">
  <span class="kv"><div class="l">Total Groups</div><div class="v">{{ $groups->count() }}</div></span>
  <span class="kv"><div class="l">Active Groups</div><div class="v">{{ $groups->where('status','active')->count() }}</div></span>
  <span class="kv"><div class="l">Total Members</div><div class="v">{{ $groups->sum(fn($g) => $g->memberships->count()) }}</div></span>
  <span class="kv"><div class="l">Total Collected</div><div class="v">₹{{ number_format($totalCollected, 0) }}</div></span>
</div>

<div class="sec">
  <h2>Groups Overview</h2>
  <table>
    <thead>
      <tr><th>Group Name</th><th>Package</th><th>Monthly</th><th>Members</th><th>Status</th><th>Start Date</th></tr>
    </thead>
    <tbody>
      @foreach ($groups as $g)
      <tr>
        <td>{{ $g->name }}</td>
        <td>{{ $g->package->name ?? '—' }}</td>
        <td>₹{{ number_format($g->package->monthly_amount ?? 0, 0) }}</td>
        <td>{{ $g->memberships->count() }} / {{ $g->total_members }}</td>
        <td>{{ ucfirst($g->status) }}</td>
        <td>{{ $g->start_date ? \Carbon\Carbon::parse($g->start_date)->format('d M Y') : '—' }}</td>
      </tr>
      @endforeach
    </tbody>
  </table>
</div>
</body>
</html>
