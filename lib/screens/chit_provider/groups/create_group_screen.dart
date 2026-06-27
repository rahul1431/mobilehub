import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/chit_package_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/provider_state.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  ChitPackageModel? _selectedPackage;
  DateTime? _startDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPackages();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary, surface: AppTheme.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a package'), backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _saving = true);

    final body = {
      'package_id': _selectedPackage!.id,
      'name': _name.text.trim(),
      if (_startDate != null) 'start_date': _startDate!.toIso8601String().split('T').first,
    };

    final ok = await context.read<ProviderState>().createGroup(body);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<ProviderState>().groupsError ?? 'Failed to create group'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = context.watch<AdminProvider>().packages.where((p) => p.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Chit Group')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Group Name *',
                hintText: 'e.g. Ganesh Gold Chit - Jan 2025',
                prefixIcon: Icon(Icons.group_work_outlined),
              ),
              validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 20),
            const Text('Select Package *',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            if (packages.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No active packages available. Ask your admin to create one.',
                    style: TextStyle(color: AppTheme.textMuted), textAlign: TextAlign.center),
              )
            else
              ...packages.map((pkg) => _PackageOption(
                    package: pkg,
                    isSelected: _selectedPackage?.id == pkg.id,
                    onTap: () => setState(() => _selectedPackage = pkg),
                  )),
            const SizedBox(height: 20),
            // Start date (optional)
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppTheme.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date (optional)',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            _startDate == null
                                ? 'Tap to set a start date'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                            style: TextStyle(
                              color: _startDate == null ? AppTheme.textMuted : Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_startDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted, size: 18),
                        onPressed: () => setState(() => _startDate = null),
                      ),
                  ],
                ),
              ),
            ),
            if (_selectedPackage != null) ...[
              const SizedBox(height: 20),
              _GroupSummary(package: _selectedPackage!),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(_saving ? 'Creating...' : 'Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageOption extends StatelessWidget {
  final ChitPackageModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageOption({required this.package, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.primary : Colors.transparent,
              border: Border.all(color: isSelected ? AppTheme.primary : Colors.white38, width: 2),
            ),
            child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(package.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                '₹${package.monthlyAmount.toStringAsFixed(0)}/mo · ${package.durationMonths}m · ${package.maxMembers} members',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ]),
          ),
          Text('${package.commissionPct.toStringAsFixed(1)}% comm',
              style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _GroupSummary extends StatelessWidget {
  final ChitPackageModel package;
  const _GroupSummary({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Group Summary',
              style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _row('Monthly Collection', '₹${_f(package.monthlyAmount)} × ${package.maxMembers} members'),
          _row('Total Pot / Cycle', '₹${_f(package.totalPot)}'),
          _row('Your Commission', '₹${_f(package.commissionPerCycle)} (${package.commissionPct}%)'),
          _row('Member Net Payout', '₹${_f(package.memberNetPayout)}'),
        ],
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            Text(v, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  String _f(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
