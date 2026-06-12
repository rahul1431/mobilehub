class UserModel {
  final String name;
  final String mobile;
  final String customerId;
  final String crmCode;
  final String address;
  final String kycStatus;
  final String accountType;

  const UserModel({
    required this.name,
    required this.mobile,
    required this.customerId,
    required this.crmCode,
    required this.address,
    required this.kycStatus,
    required this.accountType,
  });
}

class GoldOrnament {
  final String name;
  final int count;
  final double grossWeight;
  final double deduction;
  final double netWeight;
  final double ratePerGram;

  const GoldOrnament({
    required this.name,
    required this.count,
    required this.grossWeight,
    required this.deduction,
    required this.netWeight,
    required this.ratePerGram,
  });

  double get eligibleAmount => netWeight * ratePerGram;
}

class GoldLoan {
  final String loanId;
  final String scheme;
  final double amount;
  final double eligibleAmount;
  final double grossWeight;
  final double netWeight;
  final double interestRate;
  final double annualizedRate;
  final DateTime sanctionDate;
  final DateTime dueDate;
  final String status;
  final double outstandingAmount;
  final String paymentMode;
  final List<GoldOrnament> ornaments;

  const GoldLoan({
    required this.loanId,
    required this.scheme,
    required this.amount,
    required this.eligibleAmount,
    required this.grossWeight,
    required this.netWeight,
    required this.interestRate,
    required this.annualizedRate,
    required this.sanctionDate,
    required this.dueDate,
    required this.status,
    required this.outstandingAmount,
    required this.paymentMode,
    required this.ornaments,
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

// Mock data — real values from Loan Sanction Letter dated 21/03/2022
class MockData {
  static const user = UserModel(
    name: 'Pathloth Ranjith Rathod',
    mobile: '+91 95672 59926',
    customerId: '00878000011347',
    crmCode: '00878004672951',
    address: '6-4-2, Shivaji Nagar,\nSangareddy H.O, Medak,\nTelangana - 502001',
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
      loanId: '00878/MH/PI/000286',
      scheme: 'Muthoot High Value Plus',
      amount: 194000,
      eligibleAmount: 195924,
      grossWeight: 59.0,
      netWeight: 56.3,
      interestRate: 24.0,
      annualizedRate: 26.82,
      sanctionDate: DateTime(2022, 3, 21),
      dueDate: DateTime(2027, 3, 21),
      status: 'Active',
      outstandingAmount: 194000,
      paymentMode: 'Cash',
      ornaments: const [
        GoldOrnament(
          name: 'Laxmi Hara',
          count: 1,
          grossWeight: 37.600,
          deduction: 1.600,
          netWeight: 36.000,
          ratePerGram: 3480,
        ),
        GoldOrnament(
          name: 'Rings',
          count: 2,
          grossWeight: 7.900,
          deduction: 0.100,
          netWeight: 7.800,
          ratePerGram: 3480,
        ),
        GoldOrnament(
          name: 'Studs',
          count: 4,
          grossWeight: 13.500,
          deduction: 1.000,
          netWeight: 12.500,
          ratePerGram: 3480,
        ),
      ],
    ),
  ];

  static final transactions = [
    Transaction(
      id: 'TXN001',
      title: 'Loan Disbursement',
      subtitle: '00878/MH/PI/000286',
      amount: 194000,
      isCredit: true,
      date: DateTime(2022, 3, 21),
      status: 'Success',
    ),
    Transaction(
      id: 'TXN002',
      title: 'Gold Appraisal Done',
      subtitle: '7 items • 56.3g net weight',
      amount: 195924,
      isCredit: true,
      date: DateTime(2022, 3, 21),
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
      subtitle: 'NEFT / RTGS',
      amount: 10000,
      isCredit: false,
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: 'Success',
    ),
  ];

  static final branches = [
    Branch(
      name: 'Muthoot Finance - Sangareddy',
      address: 'Main Road, Sangareddy H.O, Medak',
      city: 'Sangareddy',
      phone: '08455-272323',
      distance: 0.5,
      isOpen: true,
    ),
    Branch(
      name: 'Muthoot Finance - Medak',
      address: 'Near Collectorate, Medak',
      city: 'Medak',
      phone: '08452-221100',
      distance: 3.2,
      isOpen: true,
    ),
    Branch(
      name: 'Muthoot Finance - Hyderabad',
      address: 'Begumpet, Hyderabad',
      city: 'Hyderabad',
      phone: '040-27891234',
      distance: 65.0,
      isOpen: true,
    ),
  ];
}
