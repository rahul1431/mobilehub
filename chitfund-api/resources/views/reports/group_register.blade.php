<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
  body  { font-family: DejaVu Sans, sans-serif; font-size: 11px; color: #1a1a2e; margin: 0; }
  .hdr  { background: #6C63FF; color: #fff; padding: 18px 24px; }
  .hdr h1 { margin: 0; font-size: 18px; }
  .hdr p  { margin: 3px 0 0; font-size: 10px; opacity: 0.85; }
  .meta { padding: 12px 24px; display: flex; gap: 32px; background: #f7f6ff; border-bottom: 1px solid #e0ddff; }
  .kv   { display: inline-block; margin-right: 28px; }
  .kv .l { font-size: 9px; color: #999; text-transform: uppercase; }
  .kv .v { font-weight: bold; font-size: 12px; }
  .sec  { padding: 14px 24px; }
  h2    { font-size: 13px; color: #6C63FF; margin: 0 0 8px; }
  table { width: 100%; border-collapse: collapse; }
  th    { background: #f0eeff; color: #6C63FF; font-size: 9px; padding: 7px 8px; text-align: left; border-bottom: 2px solid #6C63FF; }
  td    { padding: 7px 8px; border-bottom: 1px solid #eee; font-size: 10px; }
  .pg   { page-break-before: always; }
</style>
</head>
<body>
<div class="hdr">
  <h1>Group Register — {{ $group->name }}</h1>
  <p>Provider: {{ $group->provider->full_name ?? $group->provider->phone }} &nbsp;|&nbsp; Generated: {{ now()->format('d M Y') }}</p>
</div>

<div class="meta">
  <span class="kv"><div class="l">Package</div><div class="v">{{ $group->package->name ?? '—' }}</div></span>
  <span class="kv"><div class="l">Monthly</div><div class="v">₹{{ number_format($group->package->monthly_amount ?? 0, 0) }}</div></span>
  <span class="kv"><div class="l">Duration</div><div class="v">{{ $group->package->duration_months ?? '—' }} months</div></span>
  <span class="kv"><div class="l">Members</div><div class="v">{{ $group->memberships->count() }} / {{ $group->total_members }}</div></span>
  <span class="kv"><div class="l">Status</div><div class="v">{{ ucfirst($group->status) }}</div></span>
  <span class="kv"><div class="l">Start Date</div><div class="v">{{ $group->start_date ? \Carbon\Carbon::parse($group->start_date)->format('d M Y') : '—' }}</div></span>
</div>

<div class="sec">
  <h2>Members List</h2>
  <table>
    <thead>
      <tr>
        <th>Slot#</th><th>Name</th><th>Phone</th><th>KYC</th><th>Joined</th><th>Has Won</th>
      </tr>
    </thead>
    <tbody>
      @foreach ($group->memberships as $m)
      <tr>
        <td>{{ $m->membership_no ?? '—' }}</td>
        <td>{{ $m->member->full_name ?? '—' }}</td>
        <td>{{ $m->member->phone }}</td>
        <td>{{ ucfirst($m->member->kyc_status ?? 'pending') }}</td>
        <td>{{ $m->joined_at ? \Carbon\Carbon::parse($m->joined_at)->format('d/m/Y') : '—' }}</td>
        <td>{{ $m->has_won ? 'Yes' : 'No' }}</td>
      </tr>
      @endforeach
    </tbody>
  </table>
</div>

<div class="sec pg">
  <h2>Cycle Summary</h2>
  <table>
    <thead>
      <tr><th>Cycle</th><th>Due Date</th><th>Total Pot</th><th>Method</th><th>Winner</th><th>Winning Bid</th><th>Status</th></tr>
    </thead>
    <tbody>
      @foreach ($group->cycles as $c)
      <tr>
        <td>#{{ $c->cycle_number }}</td>
        <td>{{ $c->due_date ? $c->due_date->format('d/m/Y') : '—' }}</td>
        <td>₹{{ number_format($c->total_pot, 0) }}</td>
        <td>{{ ucfirst($c->cycle_method ?? '—') }}</td>
        <td>{{ $c->winner->full_name ?? $c->winner->phone ?? '—' }}</td>
        <td>{{ $c->winning_bid ? '₹'.number_format($c->winning_bid, 0) : '—' }}</td>
        <td>{{ ucfirst($c->status) }}</td>
      </tr>
      @endforeach
    </tbody>
  </table>
</div>
</body>
</html>
