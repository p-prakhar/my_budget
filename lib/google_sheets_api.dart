import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "mybudgetapp-355213",
  "private_key_id": "8fb1f15532d2c0dfee33ace5ebd40defada27983",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCuGtwc8qG4hIMQ\ngqPS6x84fbzsPbTr0iN62IKnyoT9v0PFqHAM/qRmkQ2109paExx6a8baqXFnltFc\n/f3/TcQzoICL1AS5GOkn7s6RoAAaW5/bNyaefGoWbL8cZK/0LhXB/DMsRTMWfy3L\nEzbWKzZEqz+PK3TzfbBza0slLpYAwoHgsOgacQGzJEDnXdNVKMbeMK3ONyKBspjf\npdNzUPUKN4S81Hsr4Pmldrv0LxuyBkT6qQZDMg/IRMgxP2THqVOjSjQwZjsDAlFn\nYQ7aEMRb7eOxtbJTdN3hZ5/m9cIpFcoGhxCrtzSbIvhZ03gqkPrlMHz4S5Ta1Uc0\nLFtaijIJAgMBAAECggEAJiRZQ3g+SLOzGOtd44fCC7i0KlcsaxtazX9gRE0gTIzZ\n1pQblCU3NAckJ0j1xZT5QLKa2m2TnBuU21gDjKpnSN4pOzjkHf7gmXB+TbXtP9kB\n0N8otUDRZv9E8P339DkiaCCNv22bjxqmmB4p/cpytaGEp6NgGDXZcbe4OzmVAC4/\nHN5ONiTsSSU7jGNDOp16oauPwi0lNgRawIJikp4tpCbi0cioiDeV016y1J38iJ9h\nrgtlv0L51cuRpXcnXCGJ/H9cOH09d4ayNXF00yMWSCrBDGBDdzt/xmLUykUzA5u4\nh/nNnJf3Ybzbbydw2x81d1nGomv0fEmQnYRszGkoLwKBgQDzn+lqPtMWOg8vDwoX\nsArBXN05l2zcMFgcqqGZwq5d2fRYXk7DBTMjYPuAuce6I6Nloke4LLzowDolvXyz\n+xp8i/cXaubvcGbuWRYgfgXXbtyiEYvF/aYdPQyqlczhts6v65/LcXjjjz2HIQbb\nud3ArsKlUH/3f/0bZfqz6bx/FwKBgQC28upUsDlkrIXO0YKkh7GCnAqZp1QUNiJZ\nrAp5M6qQqB4s/YHsvDPk46Te5Y1dtjiJpQyormCp4kdJJePJdlvTSJ6aOE7S9EUl\nYMOn7YN6cQC5RjQtsU4SA1qSX9NLbqdrWIc5s7YukVf5CS0uLQhW2OCnEq/hkdUd\nbHuOMhqL3wKBgFSm2AAm3En42pXLcAJTFSmjDuuYBidsVPGBCK3Yy6WouhKKkmuJ\nPv+oDzvnUdMH1xrVjH4ebXWidZHviYkwUz+7kpv8dUn1kI55PgsEPxtgViGqXxro\ny/OU5vXPH2W+k4rlIJ0cTJkliIePnkZzCu6Myu2OTyi8vEHs6XPiX7D5AoGAFTAQ\n33oBS52Haapt/OwSLNQxjhYI8MZMOCJqnBrVuCcgR4mckHRDdlC++WmQc7f02Ewb\nKTX4z/P62Yff16czf0a7x5SZ3GiZ0XhhcINbZMTNlqeAx4HvTrrAtI8Qg33vOclo\n78/WW5JNo/PiHaTtgFFhwzew0uj2y4+Sx6cZ1/UCgYAQ/SNj2RqiA1n6ZK0IjFUE\nLzhy2KOS4GGQ1ZAqTQIHq9j+H6Xt9Y7i8Uy5EpTCVIFT1s+o4NxijR2YqeugZDpy\n4XlmZZBzc/NxOf7iq+KrCFjRVaSO4Lh5O9J1WDtDn/6eQ3LpB0NqBFV+i/4jjQ9o\nUEYw+1Efw3Xc+n1+V+9heQ==\n-----END PRIVATE KEY-----\n",
  "client_email": "mybudgetgsheet@mybudgetapp-355213.iam.gserviceaccount.com",
  "client_id": "115131935418256065157",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/mybudgetgsheet%40mybudgetapp-355213.iam.gserviceaccount.com"
}
''';

  // set up & connect to the spreadsheet
  static const _spreadsheetId = '1tGoxPDj45gCwBfLc7W2jIgsoqAy1zZ_hL1KQsk7Eopc';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
