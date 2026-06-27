<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
  body { font-family: DejaVu Sans, sans-serif; font-size: 12px; color: #1a1a2e; margin: 0; }
  .header { background: #6C63FF; color: #fff; padding: 20px 24px; }
  .header h1 { margin: 0; font-size: 20px; }
  .header p  { margin: 4px 0 0; font-size: 11px; opacity: 0.85; }
  .section   { padding: 16px 24px; }
  .label     { color: #666; font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; }
  .value     { font-weight: bold; margin-bottom: 8px; }
  table      { width: 100%; border-collapse: collapse; margin-top: 8px; }
  th         { background: #f0eeff; color: #6C63FF; font-size: 10px; padding: 8px; text-align: left; border-bottom: 2px solid #6C63FF; }
  td         { padding: 8px; border-bottom: 1px solid #eee; font-size: 11px; }
  .paid      { color: #00C48C; font-weight: bold; }
  .pending   { color: #FF6B6B; }
  .footer    { margin-top: 24px; padding: 12px 24px; background: #f9f9f9; font-size: 9px; color: #999; }
</style>
</head>
<body>
<div class="header">
  <h1>Apna Saving — Digital Passbook</h1>
  <p>{{ $member->full_name ?? $member->phone }} &nbsp;|&nbsp; Generated: {{ now()->format('d M Y, h:i A') }}</p>
</div>

<div class="section">
  <div class="label">Member Phone</div>
  <div class="value">{{ $member->phone }}</div>
  <div class="label">KYC Status</div>
  <div class="value">{{ ucfirst($member->kyc_status ?? 'pending') }}</div>
</div>

<div class="section">
  <table>
    <thead>
      <tr>
        <th>#</th>
        <th>Group</th>
        <th>Cycle</th>
        <th>Amount</th>
        <th>Penalty</th>
        <th>Status</th>
        <th>Date</th>
      </tr>
    </thead>
    <tbody>
      @forelse ($payments as $i => $p)
      <tr>
        <td>{{ $i + 1 }}</td>
        <td>{{ $p->group->name ?? '—' }}</td>
        <td>#{{ $p->cycle->cycle_number ?? '—' }}</td>
        <td>₹{{ number_format($p->amount, 0) }}</td>
        <td>{{ $p->penalty_amount > 0 ? '₹'.number_format($p->penalty_amount,0) : '—' }}</td>
        <td class="{{ $p->status === 'paid' ? 'paid' : 'pending' }}">{{ ucfirst($p->status) }}</td>
        <td>{{ $p->paid_at ? $p->paid_at->format('d/m/Y') : '—' }}</td>
      </tr>
      @empty
      <tr><td colspan="7" style="text-align:center;color:#999;">No transactions yet.</td></tr>
      @endforelse
    </tbody>
  </table>
</div>

<div class="footer">
  This is a computer-generated document and does not require a signature. &nbsp;|&nbsp; Apna Saving, {{ now()->year }}
</div>
</body>
</html>
