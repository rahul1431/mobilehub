class UserModel {
  final String name;
  final String mobile;
  final String customerId;
  final String kycStatus;
  final String accountType;

  const UserModel({
    required this.name,
    required this.mobile,
    required this.customerId,
    required this.kycStatus,
    required this.accountType,
  });
}

class GoldLoan {
  final String loanId;
  final double amount;
  final double goldWeight;
  final double interestRate;
  final DateTime dueDate;
  final String status;
  final double outstandingAmount;

  const GoldLoan({
    required this.loanId,
    required this.amount,
    required this.goldWeight,
    required this.interestRate,
    required this.dueDate,
    required this.status,
    required this.outstandingAmount,
  });
}

class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final DateTime date;
  final String status;

  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.status,
  });
}

class GoldRate {
  final double rate22k;
  final double rate24k;
  final double change;
  final bool isUp;
  final DateTime updatedAt;

  const GoldRate({
    required this.rate22k,
    required this.rate24k,
    required this.change,
    required this.isUp,
    required this.updatedAt,
  });
}

class Branch {
  final String name;
  final String address;
  final String city;
  final String phone;
  final double distance;
  final bool isOpen;

  const Branch({
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.distance,
    required this.isOpen,
  });
}

// Mock data
class MockData {
  static const user = UserModel(
    name: 'Rahul Kumar',
    mobile: '+91 98765 43210',
    customerId: 'MF20241234',
    kycStatus: 'Verified',
    accountType: 'Premium',
  );

  static final goldRate = GoldRate(
    rate22k: 6245.0,
    rate24k: 6810.0,
    change: 0.85,
    isUp: true,
    updatedAt: DateTime.now(),
  );

  static final loans = [
    GoldLoan(
      loanId: 'GL-2024-001',
      amount: 50000,
      goldWeight: 10.5,
      interestRate: 12.0,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      status: 'Active',
      outstandingAmount: 52500,
    ),
    GoldLoan(
      loanId: 'GL-2024-002',
      amount: 25000,
      goldWeight: 5.2,
      interestRate: 12.0,
      dueDate: DateTime.now().add(const Duration(days: 60)),
      status: 'Active',
      outstandingAmount: 26200,
    ),
  ];

  static final transactions = [
    Transaction(
      id: 'TXN001',
      title: 'EMI Payment',
      subtitle: 'Gold Loan GL-2024-001',
      amount: 5000,
      isCredit: false,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Success',
    ),
    Transaction(
      id: 'TXN002',
      title: 'Loan Disbursement',
      subtitle: 'Gold Loan GL-2024-002',
      amount: 25000,
      isCredit: true,
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: 'Success',
    ),
    Transaction(
      id: 'TXN003',
      title: 'Digital Gold Purchase',
      subtitle: '0.5g Gold',
      amount: 3405,
      isCredit: false,
      date: DateTime.now().subtract(const Duration(days: 10)),
      status: 'Success',
    ),
    Transaction(
      id: 'TXN004',
      title: 'Money Transfer',
      subtitle: 'To: John Doe',
      amount: 10000,
      isCredit: false,
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: 'Success',
    ),
  ];

  static final branches = [
    Branch(
      name: 'Muthoot Finance - MG Road',
      address: '45, MG Road, Near Metro Station',
      city: 'Bangalore',
      phone: '080-41234567',
      distance: 0.8,
      isOpen: true,
    ),
    Branch(
      name: 'Muthoot Finance - Koramangala',
      address: '12, 80 Feet Road, 4th Block',
      city: 'Bangalore',
      phone: '080-41234568',
      distance: 2.3,
      isOpen: true,
    ),
    Branch(
      name: 'Muthoot Finance - Indiranagar',
      address: '100 Feet Road, HAL 2nd Stage',
      city: 'Bangalore',
      phone: '080-41234569',
      distance: 3.7,
      isOpen: false,
    ),
  ];
}
