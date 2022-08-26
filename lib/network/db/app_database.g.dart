// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  NewTicketDao? _newTicketDaoInstance;

  TicketForTheDayDao? _ticketForTheDayDaoInstance;

  AmcTicketDetailsDao? _amcTicketDetailsDaoInstance;

  OngoingTicketDao? _ongoingTicketDaoInstance;

  ConsumedSpareRequestDataDao? _consumedSpareRequestDataDaoInstance;

  SpareRequestDataDao? _spareRequestDataDaoInstance;

  InstallationReportDataDao? _installationReportDataDaoInstance;

  SearchAMCContractDataDao? _searchAMCContractDataDaoInstance;

  TravelUpdateRequestDataDao? _travelUpdateRequestDataDaoInstance;

  SerialNoDataDao? _serialNoDataDaoInstance;

  NewAMCCreationDataDao? _newAMCCreationDataDaoInstance;

  AssessmentQuestionDataDao? _assessmentQuestionDataDaoInstance;

  AssessmentQuizDataDao? _assessmentQuizDataDaoInstance;

  TrainingListDataDao? _trainingListDataDaoInstance;

  SmartScheduleDataDao? _smartScheduleDataDaoInstance;

  DirectionDetailsDao? _directionDetailsDaoInstance;

  SelectedOnHandSpareDao? _selectedOnHandSpareDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `NewTicketTable` (`id` INTEGER NOT NULL, `ticketId` TEXT NOT NULL, `priority` TEXT NOT NULL, `location` TEXT NOT NULL, `customerName` TEXT NOT NULL, `customerMobile` TEXT NOT NULL, `serialNo` TEXT NOT NULL, `modelNo` TEXT NOT NULL, `customerAddress` TEXT NOT NULL, `callCategory` TEXT NOT NULL, `contractType` TEXT NOT NULL, `problemDescription` TEXT NOT NULL, `endUserName` TEXT NOT NULL, `endUserMobile` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TicketForTheDayTable` (`id` INTEGER NOT NULL, `technicianCode` TEXT NOT NULL, `ticketId` TEXT NOT NULL, `priority` TEXT NOT NULL, `location` TEXT NOT NULL, `customerName` TEXT NOT NULL, `customerMobile` TEXT NOT NULL, `endUserName` TEXT NOT NULL, `endUserMobile` TEXT NOT NULL, `serialNo` TEXT NOT NULL, `modelNo` TEXT NOT NULL, `customerAddress` TEXT NOT NULL, `callCategory` TEXT NOT NULL, `contractType` TEXT NOT NULL, `problemDescription` TEXT NOT NULL, `ticketStatus` TEXT NOT NULL, `nextVisit` TEXT NOT NULL, `latitude` TEXT NOT NULL, `longitude` TEXT NOT NULL, `statusCode` INTEGER NOT NULL, `serviceId` INTEGER NOT NULL, `resolutionTime` TEXT NOT NULL, `workType` TEXT NOT NULL, `ticketDate` TEXT NOT NULL, `ticketState` TEXT NOT NULL, `ticketUpdate` TEXT NOT NULL, `travelPlanTransport` TEXT NOT NULL, `ticketType` INTEGER NOT NULL, `partNumber` TEXT NOT NULL, `warrantyStatus` TEXT NOT NULL, `contractExpiryDate` TEXT NOT NULL, `priceType` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AmcDetailsTicketTable` (`id` INTEGER NOT NULL, `technicianCode` TEXT NOT NULL, `ticketId` TEXT NOT NULL, `customerName` TEXT NOT NULL, `contactNumber` TEXT NOT NULL, `plotNumber` TEXT NOT NULL, `street` TEXT NOT NULL, `country` TEXT NOT NULL, `state` TEXT NOT NULL, `city` TEXT NOT NULL, `location` TEXT NOT NULL, `amcType` TEXT NOT NULL, `amcDuration` TEXT NOT NULL, `productName` TEXT NOT NULL, `subProductName` TEXT NOT NULL, `modelNo` TEXT NOT NULL, `amount` INTEGER NOT NULL, `quantity` TEXT NOT NULL, `totalAmount` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `OngoingTicketTable` (`id` INTEGER NOT NULL, `technicianCode` TEXT NOT NULL, `ticketId` TEXT NOT NULL, `priority` TEXT NOT NULL, `location` TEXT NOT NULL, `customerName` TEXT NOT NULL, `customerMobile` TEXT NOT NULL, `serialNo` TEXT NOT NULL, `modelNo` TEXT NOT NULL, `customerAddress` TEXT NOT NULL, `callCategory` TEXT NOT NULL, `contractType` TEXT NOT NULL, `problemDescription` TEXT NOT NULL, `ticketStatus` TEXT NOT NULL, `nextVisit` TEXT NOT NULL, `endUserName` TEXT NOT NULL, `endUserMobileNumber` TEXT NOT NULL, `siteID` TEXT NOT NULL, `segment` TEXT NOT NULL, `segmentID` TEXT NOT NULL, `application` TEXT NOT NULL, `batteryBankID` TEXT NOT NULL, `flag` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ConsumedSpareRequestDataTable` (`id` INTEGER NOT NULL, `spareId` TEXT NOT NULL, `spareCode` TEXT NOT NULL, `spareName` TEXT NOT NULL, `quantity` INTEGER NOT NULL, `upDateSpare` INTEGER NOT NULL, `updateQuantity` INTEGER NOT NULL, `price` INTEGER NOT NULL, `location` TEXT NOT NULL, `spareLocationId` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SpareRequestDataTable` (`id` INTEGER NOT NULL, `spareId` TEXT NOT NULL, `spareCode` TEXT NOT NULL, `spareName` TEXT NOT NULL, `productId` INTEGER NOT NULL, `productSubId` INTEGER NOT NULL, `location` TEXT NOT NULL, `quantity` INTEGER NOT NULL, `price` REAL NOT NULL, `spareModel` TEXT NOT NULL, `upDateSpare` INTEGER NOT NULL, `updateQuantity` INTEGER NOT NULL, `isChargeable` INTEGER NOT NULL, `leadTime` INTEGER NOT NULL, `totalCost` REAL NOT NULL, `locationId` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `InstallationReportDataTable` (`id` INTEGER NOT NULL, `ser_check_list_id` INTEGER NOT NULL, `service_group` TEXT NOT NULL, `description` TEXT NOT NULL, `quation_type` INTEGER NOT NULL, `product_id` TEXT NOT NULL, `answer_value` TEXT NOT NULL, `remarks` TEXT NOT NULL, `qsatype1` INTEGER NOT NULL, `qsatype2` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SearchAMCContractDataTable` (`id` INTEGER, `customerCode` TEXT, `customerName` TEXT, `emailId` TEXT, `contactNumber` TEXT, `contractId` INTEGER, `productId` INTEGER, `productName` TEXT, `subCategoryId` INTEGER, `subCategoryName` TEXT, `modelNo` TEXT, `serialNo` TEXT, `contractType` TEXT, `plotNumber` TEXT, `street` TEXT, `postCode` INTEGER, `country` TEXT, `state` TEXT, `city` TEXT, `location` TEXT, `contractDuration` INTEGER, `contractAmmount` INTEGER, `startDate` TEXT, `expiryDay` TEXT, `invoiceId` TEXT, `flag` INTEGER, `daysLeft` INTEGER, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TravelUpdateRequestData` (`id` INTEGER, `ticketId` TEXT, `modeOfTravel` TEXT, `noOfKmTravelled` TEXT, `estimatedTime` TEXT, `startDate` TEXT, `endDate` TEXT, `imageSelected` TEXT, `imagePath` TEXT, `expenses` TEXT, `adapterPosition` INTEGER, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SerialNoDataTable` (`id` INTEGER NOT NULL, `serialNo` TEXT NOT NULL, `ticketId` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `NewAMCCreationDataTable` (`id` INTEGER, `contactNumber` TEXT, `customerName` TEXT, `customerEmail` TEXT, `flatNoStreet` TEXT, `street` TEXT, `postCode` INTEGER, `countryId` INTEGER, `stateId` INTEGER, `cityId` INTEGER, `locationId` INTEGER, `priority` TEXT, `amcTypeId` INTEGER, `amcPeriod` INTEGER, `startDate` TEXT, `productId` INTEGER, `subCategoryId` INTEGER, `callCategoryId` INTEGER, `modelNo` TEXT, `invoiceNo` TEXT, `totalAmount` INTEGER, `modeOfPayment` TEXT, `checkable` INTEGER, `customerCode` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AssessmentQuestionDataTable` (`id` INTEGER, `assessmentId` INTEGER, `assessmentName` TEXT, `totalQuations` INTEGER, `quationToAssessment` INTEGER, `score` INTEGER, `status` TEXT, `trainingId` TEXT, `threshold` INTEGER, `assessment_status` INTEGER, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AssessmentQuizDataTable` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `quationId` INTEGER, `assessment_id` INTEGER, `quation` TEXT, `optionA` TEXT, `optionB` TEXT, `optionC` TEXT, `optionD` TEXT, `correctAnswer` TEXT, `updateAnswer_a` INTEGER, `updateAnswer_b` INTEGER, `updateAnswer_c` INTEGER, `updateAnswer_d` INTEGER, `your_answer` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TrainingListDataTable` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `training_id` TEXT, `training_title` TEXT, `certificate_id` TEXT, `training_thumb_image` TEXT, `training_content_type` TEXT, `training_content` TEXT, `trainingPdfImage` TEXT, `trainingVideoImage` TEXT, `trainingWordImage` TEXT, `trainingLinkImage` TEXT, `pdfCount` INTEGER, `videoCount` INTEGER, `wordCount` INTEGER, `linkCount` INTEGER, `assessment_id` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SmartScheduleDataTable` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `smartschedule_id` INTEGER, `smartschedule_date` TEXT, `smartschedule_time` TEXT, `smartschedule_tittle` TEXT, `smartschedule_desc` TEXT, `smartschedule_update` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DirectionDetailsTable` (`id` INTEGER, `distance` TEXT, `duration` TEXT, `startAddress` TEXT, `endAddress` TEXT, `ticketId` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SelectedOnHandSpareDataTable` (`id` INTEGER, `spareId` TEXT, `spareCode` TEXT, `spareName` TEXT, `quantity` INTEGER, `location` TEXT, `isSelectedSpare` INTEGER, `locationId` INTEGER, `ticketId` TEXT, `price` REAL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  NewTicketDao get newTicketDao {
    return _newTicketDaoInstance ??= _$NewTicketDao(database, changeListener);
  }

  @override
  TicketForTheDayDao get ticketForTheDayDao {
    return _ticketForTheDayDaoInstance ??=
        _$TicketForTheDayDao(database, changeListener);
  }

  @override
  AmcTicketDetailsDao get amcTicketDetailsDao {
    return _amcTicketDetailsDaoInstance ??=
        _$AmcTicketDetailsDao(database, changeListener);
  }

  @override
  OngoingTicketDao get ongoingTicketDao {
    return _ongoingTicketDaoInstance ??=
        _$OngoingTicketDao(database, changeListener);
  }

  @override
  ConsumedSpareRequestDataDao get consumedSpareRequestDataDao {
    return _consumedSpareRequestDataDaoInstance ??=
        _$ConsumedSpareRequestDataDao(database, changeListener);
  }

  @override
  SpareRequestDataDao get spareRequestDataDao {
    return _spareRequestDataDaoInstance ??=
        _$SpareRequestDataDao(database, changeListener);
  }

  @override
  InstallationReportDataDao get installationReportDataDao {
    return _installationReportDataDaoInstance ??=
        _$InstallationReportDataDao(database, changeListener);
  }

  @override
  SearchAMCContractDataDao get searchAMCContractDataDao {
    return _searchAMCContractDataDaoInstance ??=
        _$SearchAMCContractDataDao(database, changeListener);
  }

  @override
  TravelUpdateRequestDataDao get travelUpdateRequestDataDao {
    return _travelUpdateRequestDataDaoInstance ??=
        _$TravelUpdateRequestDataDao(database, changeListener);
  }

  @override
  SerialNoDataDao get serialNoDataDao {
    return _serialNoDataDaoInstance ??=
        _$SerialNoDataDao(database, changeListener);
  }

  @override
  NewAMCCreationDataDao get newAMCCreationDataDao {
    return _newAMCCreationDataDaoInstance ??=
        _$NewAMCCreationDataDao(database, changeListener);
  }

  @override
  AssessmentQuestionDataDao get assessmentQuestionDataDao {
    return _assessmentQuestionDataDaoInstance ??=
        _$AssessmentQuestionDataDao(database, changeListener);
  }

  @override
  AssessmentQuizDataDao get assessmentQuizDataDao {
    return _assessmentQuizDataDaoInstance ??=
        _$AssessmentQuizDataDao(database, changeListener);
  }

  @override
  TrainingListDataDao get trainingListDataDao {
    return _trainingListDataDaoInstance ??=
        _$TrainingListDataDao(database, changeListener);
  }

  @override
  SmartScheduleDataDao get smartScheduleDataDao {
    return _smartScheduleDataDaoInstance ??=
        _$SmartScheduleDataDao(database, changeListener);
  }

  @override
  DirectionDetailsDao get directionDetailsDao {
    return _directionDetailsDaoInstance ??=
        _$DirectionDetailsDao(database, changeListener);
  }

  @override
  SelectedOnHandSpareDao get selectedOnHandSpareDao {
    return _selectedOnHandSpareDaoInstance ??=
        _$SelectedOnHandSpareDao(database, changeListener);
  }
}

class _$NewTicketDao extends NewTicketDao {
  _$NewTicketDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _newTicketTableInsertionAdapter = InsertionAdapter(
            database,
            'NewTicketTable',
            (NewTicketTable item) => <String, Object?>{
                  'id': item.id,
                  'ticketId': item.ticketId,
                  'priority': item.priority,
                  'location': item.location,
                  'customerName': item.customerName,
                  'customerMobile': item.customerMobile,
                  'serialNo': item.serialNo,
                  'modelNo': item.modelNo,
                  'customerAddress': item.customerAddress,
                  'callCategory': item.callCategory,
                  'contractType': item.contractType,
                  'problemDescription': item.problemDescription,
                  'endUserName': item.endUserName,
                  'endUserMobile': item.endUserMobile
                },
            changeListener),
        _newTicketTableDeletionAdapter = DeletionAdapter(
            database,
            'NewTicketTable',
            ['id'],
            (NewTicketTable item) => <String, Object?>{
                  'id': item.id,
                  'ticketId': item.ticketId,
                  'priority': item.priority,
                  'location': item.location,
                  'customerName': item.customerName,
                  'customerMobile': item.customerMobile,
                  'serialNo': item.serialNo,
                  'modelNo': item.modelNo,
                  'customerAddress': item.customerAddress,
                  'callCategory': item.callCategory,
                  'contractType': item.contractType,
                  'problemDescription': item.problemDescription,
                  'endUserName': item.endUserName,
                  'endUserMobile': item.endUserMobile
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NewTicketTable> _newTicketTableInsertionAdapter;

  final DeletionAdapter<NewTicketTable> _newTicketTableDeletionAdapter;

  @override
  Future<List<NewTicketTable>> findAllNewTicket() async {
    return _queryAdapter.queryList('SELECT * FROM NewTicketTable',
        mapper: (Map<String, Object?> row) => NewTicketTable(
            row['id'] as int,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['endUserName'] as String,
            row['endUserMobile'] as String));
  }

  @override
  Stream<NewTicketTable?> findNewTicketById(String ticketId, String id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM NewTicketTable WHERE ticketId = ?1 AND id = ?2',
        mapper: (Map<String, Object?> row) => NewTicketTable(
            row['id'] as int,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['endUserName'] as String,
            row['endUserMobile'] as String),
        arguments: [ticketId, id],
        queryableName: 'NewTicketTable',
        isView: false);
  }

  @override
  Stream<NewTicketTable?> findNewTicketByTicketId(String ticketId) {
    return _queryAdapter.queryStream(
        'SELECT * FROM NewTicketTable WHERE ticketId = ?1',
        mapper: (Map<String, Object?> row) => NewTicketTable(
            row['id'] as int,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['endUserName'] as String,
            row['endUserMobile'] as String),
        arguments: [ticketId],
        queryableName: 'NewTicketTable',
        isView: false);
  }

  @override
  Future<void> deleteNewTicketItem(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM NewTicketTable WHERE id =?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteNewTicketTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM NewTicketTable');
  }

  @override
  Future<void> insertNewTicket(NewTicketTable newTicketTable) async {
    await _newTicketTableInsertionAdapter.insert(
        newTicketTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteNewTicket(NewTicketTable newTicketTable) async {
    await _newTicketTableDeletionAdapter.delete(newTicketTable);
  }
}

class _$TicketForTheDayDao extends TicketForTheDayDao {
  _$TicketForTheDayDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _ticketForTheDayTableInsertionAdapter = InsertionAdapter(
            database,
            'TicketForTheDayTable',
            (TicketForTheDayTable item) => <String, Object?>{
                  'id': item.id,
                  'technicianCode': item.technicianCode,
                  'ticketId': item.ticketId,
                  'priority': item.priority,
                  'location': item.location,
                  'customerName': item.customerName,
                  'customerMobile': item.customerMobile,
                  'endUserName': item.endUserName,
                  'endUserMobile': item.endUserMobile,
                  'serialNo': item.serialNo,
                  'modelNo': item.modelNo,
                  'customerAddress': item.customerAddress,
                  'callCategory': item.callCategory,
                  'contractType': item.contractType,
                  'problemDescription': item.problemDescription,
                  'ticketStatus': item.ticketStatus,
                  'nextVisit': item.nextVisit,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'statusCode': item.statusCode,
                  'serviceId': item.serviceId,
                  'resolutionTime': item.resolutionTime,
                  'workType': item.workType,
                  'ticketDate': item.ticketDate,
                  'ticketState': item.ticketState,
                  'ticketUpdate': item.ticketUpdate,
                  'travelPlanTransport': item.travelPlanTransport,
                  'ticketType': item.ticketType,
                  'partNumber': item.partNumber,
                  'warrantyStatus': item.warrantyStatus,
                  'contractExpiryDate': item.contractExpiryDate,
                  'priceType': item.priceType
                },
            changeListener),
        _ticketForTheDayTableDeletionAdapter = DeletionAdapter(
            database,
            'TicketForTheDayTable',
            ['id'],
            (TicketForTheDayTable item) => <String, Object?>{
                  'id': item.id,
                  'technicianCode': item.technicianCode,
                  'ticketId': item.ticketId,
                  'priority': item.priority,
                  'location': item.location,
                  'customerName': item.customerName,
                  'customerMobile': item.customerMobile,
                  'endUserName': item.endUserName,
                  'endUserMobile': item.endUserMobile,
                  'serialNo': item.serialNo,
                  'modelNo': item.modelNo,
                  'customerAddress': item.customerAddress,
                  'callCategory': item.callCategory,
                  'contractType': item.contractType,
                  'problemDescription': item.problemDescription,
                  'ticketStatus': item.ticketStatus,
                  'nextVisit': item.nextVisit,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'statusCode': item.statusCode,
                  'serviceId': item.serviceId,
                  'resolutionTime': item.resolutionTime,
                  'workType': item.workType,
                  'ticketDate': item.ticketDate,
                  'ticketState': item.ticketState,
                  'ticketUpdate': item.ticketUpdate,
                  'travelPlanTransport': item.travelPlanTransport,
                  'ticketType': item.ticketType,
                  'partNumber': item.partNumber,
                  'warrantyStatus': item.warrantyStatus,
                  'contractExpiryDate': item.contractExpiryDate,
                  'priceType': item.priceType
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TicketForTheDayTable>
      _ticketForTheDayTableInsertionAdapter;

  final DeletionAdapter<TicketForTheDayTable>
      _ticketForTheDayTableDeletionAdapter;

  @override
  Future<List<TicketForTheDayTable>> findAllTicketForTheDay() async {
    return _queryAdapter.queryList('SELECT * FROM TicketForTheDayTable',
        mapper: (Map<String, Object?> row) => TicketForTheDayTable(
            row['id'] as int,
            row['technicianCode'] as String,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['endUserName'] as String,
            row['endUserMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['ticketStatus'] as String,
            row['nextVisit'] as String,
            row['latitude'] as String,
            row['longitude'] as String,
            row['statusCode'] as int,
            row['serviceId'] as int,
            row['resolutionTime'] as String,
            row['workType'] as String,
            row['ticketDate'] as String,
            row['ticketState'] as String,
            row['ticketUpdate'] as String,
            row['travelPlanTransport'] as String,
            row['ticketType'] as int,
            row['partNumber'] as String,
            row['warrantyStatus'] as String,
            row['contractExpiryDate'] as String,
            row['priceType'] as String));
  }

  @override
  Stream<TicketForTheDayTable?> findTicketForTheDayById(
      String ticketId, String id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM TicketForTheDayTable WHERE ticketId = ?1 AND id = ?2',
        mapper: (Map<String, Object?> row) => TicketForTheDayTable(
            row['id'] as int,
            row['technicianCode'] as String,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['endUserName'] as String,
            row['endUserMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['ticketStatus'] as String,
            row['nextVisit'] as String,
            row['latitude'] as String,
            row['longitude'] as String,
            row['statusCode'] as int,
            row['serviceId'] as int,
            row['resolutionTime'] as String,
            row['workType'] as String,
            row['ticketDate'] as String,
            row['ticketState'] as String,
            row['ticketUpdate'] as String,
            row['travelPlanTransport'] as String,
            row['ticketType'] as int,
            row['partNumber'] as String,
            row['warrantyStatus'] as String,
            row['contractExpiryDate'] as String,
            row['priceType'] as String),
        arguments: [ticketId, id],
        queryableName: 'TicketForTheDayTable',
        isView: false);
  }

  @override
  Future<List<TicketForTheDayTable>> findTicketForTheDayByTicketId(
      String ticketId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TicketForTheDayTable WHERE ticketId = ?1',
        mapper: (Map<String, Object?> row) => TicketForTheDayTable(
            row['id'] as int,
            row['technicianCode'] as String,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['endUserName'] as String,
            row['endUserMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['ticketStatus'] as String,
            row['nextVisit'] as String,
            row['latitude'] as String,
            row['longitude'] as String,
            row['statusCode'] as int,
            row['serviceId'] as int,
            row['resolutionTime'] as String,
            row['workType'] as String,
            row['ticketDate'] as String,
            row['ticketState'] as String,
            row['ticketUpdate'] as String,
            row['travelPlanTransport'] as String,
            row['ticketType'] as int,
            row['partNumber'] as String,
            row['warrantyStatus'] as String,
            row['contractExpiryDate'] as String,
            row['priceType'] as String),
        arguments: [ticketId]);
  }

  @override
  Future<void> updateTravelPlanTicketData(
      String travelPlanTransport, String ticketId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE TicketForTheDayTable SET travelPlanTransport = ?1 WHERE ticketId =?2',
        arguments: [travelPlanTransport, ticketId]);
  }

  @override
  Future<void> updateTicketData(String status, String ticketId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE TicketForTheDayTable SET ticketStatus = ?1 WHERE ticketId =?2',
        arguments: [status, ticketId]);
  }

  @override
  Future<void> updateTicketStatusData(
      String ticketUpdate, String ticketId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE TicketForTheDayTable SET ticketUpdate = ?1 WHERE ticketId =?2',
        arguments: [ticketUpdate, ticketId]);
  }

  @override
  Future<void> deleteTicketForTheDayItem(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM TicketForTheDayTable WHERE id =?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteTicketForTheDayTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM TicketForTheDayTable');
  }

  @override
  Future<void> insertTicketForTheDay(
      TicketForTheDayTable newTicketTable) async {
    await _ticketForTheDayTableInsertionAdapter.insert(
        newTicketTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTicketForTheDay(
      TicketForTheDayTable newTicketTable) async {
    await _ticketForTheDayTableDeletionAdapter.delete(newTicketTable);
  }
}

class _$AmcTicketDetailsDao extends AmcTicketDetailsDao {
  _$AmcTicketDetailsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _amcDetailsTicketTableInsertionAdapter = InsertionAdapter(
            database,
            'AmcDetailsTicketTable',
            (AmcDetailsTicketTable item) => <String, Object?>{
                  'id': item.id,
                  'technicianCode': item.technicianCode,
                  'ticketId': item.ticketId,
                  'customerName': item.customerName,
                  'contactNumber': item.contactNumber,
                  'plotNumber': item.plotNumber,
                  'street': item.street,
                  'country': item.country,
                  'state': item.state,
                  'city': item.city,
                  'location': item.location,
                  'amcType': item.amcType,
                  'amcDuration': item.amcDuration,
                  'productName': item.productName,
                  'subProductName': item.subProductName,
                  'modelNo': item.modelNo,
                  'amount': item.amount,
                  'quantity': item.quantity,
                  'totalAmount': item.totalAmount
                }),
        _amcDetailsTicketTableDeletionAdapter = DeletionAdapter(
            database,
            'AmcDetailsTicketTable',
            ['id'],
            (AmcDetailsTicketTable item) => <String, Object?>{
                  'id': item.id,
                  'technicianCode': item.technicianCode,
                  'ticketId': item.ticketId,
                  'customerName': item.customerName,
                  'contactNumber': item.contactNumber,
                  'plotNumber': item.plotNumber,
                  'street': item.street,
                  'country': item.country,
                  'state': item.state,
                  'city': item.city,
                  'location': item.location,
                  'amcType': item.amcType,
                  'amcDuration': item.amcDuration,
                  'productName': item.productName,
                  'subProductName': item.subProductName,
                  'modelNo': item.modelNo,
                  'amount': item.amount,
                  'quantity': item.quantity,
                  'totalAmount': item.totalAmount
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AmcDetailsTicketTable>
      _amcDetailsTicketTableInsertionAdapter;

  final DeletionAdapter<AmcDetailsTicketTable>
      _amcDetailsTicketTableDeletionAdapter;

  @override
  Future<List<AmcDetailsTicketTable>> findAllAmcTicketDetails() async {
    return _queryAdapter.queryList('SELECT * FROM AmcDetailsTicketTable',
        mapper: (Map<String, Object?> row) => AmcDetailsTicketTable(
            row['id'] as int,
            row['technicianCode'] as String,
            row['ticketId'] as String,
            row['customerName'] as String,
            row['contactNumber'] as String,
            row['plotNumber'] as String,
            row['street'] as String,
            row['country'] as String,
            row['state'] as String,
            row['city'] as String,
            row['location'] as String,
            row['amcType'] as String,
            row['amcDuration'] as String,
            row['productName'] as String,
            row['subProductName'] as String,
            row['modelNo'] as String,
            row['amount'] as int,
            row['quantity'] as String,
            row['totalAmount'] as String));
  }

  @override
  Future<List<AmcDetailsTicketTable>> findAmcTicketDetailsByTicketId(
      String ticketId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM AmcDetailsTicketTable WHERE ticketId = ?1',
        mapper: (Map<String, Object?> row) => AmcDetailsTicketTable(
            row['id'] as int,
            row['technicianCode'] as String,
            row['ticketId'] as String,
            row['customerName'] as String,
            row['contactNumber'] as String,
            row['plotNumber'] as String,
            row['street'] as String,
            row['country'] as String,
            row['state'] as String,
            row['city'] as String,
            row['location'] as String,
            row['amcType'] as String,
            row['amcDuration'] as String,
            row['productName'] as String,
            row['subProductName'] as String,
            row['modelNo'] as String,
            row['amount'] as int,
            row['quantity'] as String,
            row['totalAmount'] as String),
        arguments: [ticketId]);
  }

  @override
  Future<void> deleteAmcTicketDetailsItem(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM AmcDetailsTicketTable WHERE id =?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteAmcTicketDetailsTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM AmcDetailsTicketTable');
  }

  @override
  Future<void> insertAmcTicketDetails(
      AmcDetailsTicketTable newTicketTable) async {
    await _amcDetailsTicketTableInsertionAdapter.insert(
        newTicketTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAmcTicketDetails(
      AmcDetailsTicketTable newTicketTable) async {
    await _amcDetailsTicketTableDeletionAdapter.delete(newTicketTable);
  }
}

class _$OngoingTicketDao extends OngoingTicketDao {
  _$OngoingTicketDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _ongoingTicketTableInsertionAdapter = InsertionAdapter(
            database,
            'OngoingTicketTable',
            (OngoingTicketTable item) => <String, Object?>{
                  'id': item.id,
                  'technicianCode': item.technicianCode,
                  'ticketId': item.ticketId,
                  'priority': item.priority,
                  'location': item.location,
                  'customerName': item.customerName,
                  'customerMobile': item.customerMobile,
                  'serialNo': item.serialNo,
                  'modelNo': item.modelNo,
                  'customerAddress': item.customerAddress,
                  'callCategory': item.callCategory,
                  'contractType': item.contractType,
                  'problemDescription': item.problemDescription,
                  'ticketStatus': item.ticketStatus,
                  'nextVisit': item.nextVisit,
                  'endUserName': item.endUserName,
                  'endUserMobileNumber': item.endUserMobileNumber,
                  'siteID': item.siteID,
                  'segment': item.segment,
                  'segmentID': item.segmentID,
                  'application': item.application,
                  'batteryBankID': item.batteryBankID,
                  'flag': item.flag
                }),
        _ongoingTicketTableDeletionAdapter = DeletionAdapter(
            database,
            'OngoingTicketTable',
            ['id'],
            (OngoingTicketTable item) => <String, Object?>{
                  'id': item.id,
                  'technicianCode': item.technicianCode,
                  'ticketId': item.ticketId,
                  'priority': item.priority,
                  'location': item.location,
                  'customerName': item.customerName,
                  'customerMobile': item.customerMobile,
                  'serialNo': item.serialNo,
                  'modelNo': item.modelNo,
                  'customerAddress': item.customerAddress,
                  'callCategory': item.callCategory,
                  'contractType': item.contractType,
                  'problemDescription': item.problemDescription,
                  'ticketStatus': item.ticketStatus,
                  'nextVisit': item.nextVisit,
                  'endUserName': item.endUserName,
                  'endUserMobileNumber': item.endUserMobileNumber,
                  'siteID': item.siteID,
                  'segment': item.segment,
                  'segmentID': item.segmentID,
                  'application': item.application,
                  'batteryBankID': item.batteryBankID,
                  'flag': item.flag
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<OngoingTicketTable>
      _ongoingTicketTableInsertionAdapter;

  final DeletionAdapter<OngoingTicketTable> _ongoingTicketTableDeletionAdapter;

  @override
  Future<List<OngoingTicketTable>> findAllOngoingTicket() async {
    return _queryAdapter.queryList('SELECT * FROM OngoingTicketTable',
        mapper: (Map<String, Object?> row) => OngoingTicketTable(
            row['id'] as int,
            row['technicianCode'] as String,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['ticketStatus'] as String,
            row['nextVisit'] as String,
            row['endUserName'] as String,
            row['endUserMobileNumber'] as String,
            row['siteID'] as String,
            row['segment'] as String,
            row['segmentID'] as String,
            row['application'] as String,
            row['batteryBankID'] as String,
            row['flag'] as int));
  }

  @override
  Future<List<OngoingTicketTable?>> findOngoingTicketById(
      String ticket_id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM OngoingTicketTable WHERE ticketId = ?1',
        mapper: (Map<String, Object?> row) => OngoingTicketTable(
            row['id'] as int,
            row['technicianCode'] as String,
            row['ticketId'] as String,
            row['priority'] as String,
            row['location'] as String,
            row['customerName'] as String,
            row['customerMobile'] as String,
            row['serialNo'] as String,
            row['modelNo'] as String,
            row['customerAddress'] as String,
            row['callCategory'] as String,
            row['contractType'] as String,
            row['problemDescription'] as String,
            row['ticketStatus'] as String,
            row['nextVisit'] as String,
            row['endUserName'] as String,
            row['endUserMobileNumber'] as String,
            row['siteID'] as String,
            row['segment'] as String,
            row['segmentID'] as String,
            row['application'] as String,
            row['batteryBankID'] as String,
            row['flag'] as int),
        arguments: [ticket_id]);
  }

  @override
  Future<void> deleteOngoingTicketItem(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM OngoingTicketTable WHERE id =?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteOngoingTicketTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM OngoingTicketTable');
  }

  @override
  Future<void> insertOngoingTicket(OngoingTicketTable newTicketTable) async {
    await _ongoingTicketTableInsertionAdapter.insert(
        newTicketTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteOngoingTicket(OngoingTicketTable newTicketTable) async {
    await _ongoingTicketTableDeletionAdapter.delete(newTicketTable);
  }
}

class _$ConsumedSpareRequestDataDao extends ConsumedSpareRequestDataDao {
  _$ConsumedSpareRequestDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _consumedSpareRequestDataTableInsertionAdapter = InsertionAdapter(
            database,
            'ConsumedSpareRequestDataTable',
            (ConsumedSpareRequestDataTable item) => <String, Object?>{
                  'id': item.id,
                  'spareId': item.spareId,
                  'spareCode': item.spareCode,
                  'spareName': item.spareName,
                  'quantity': item.quantity,
                  'upDateSpare': item.upDateSpare ? 1 : 0,
                  'updateQuantity': item.updateQuantity,
                  'price': item.price,
                  'location': item.location,
                  'spareLocationId': item.spareLocationId
                }),
        _consumedSpareRequestDataTableDeletionAdapter = DeletionAdapter(
            database,
            'ConsumedSpareRequestDataTable',
            ['id'],
            (ConsumedSpareRequestDataTable item) => <String, Object?>{
                  'id': item.id,
                  'spareId': item.spareId,
                  'spareCode': item.spareCode,
                  'spareName': item.spareName,
                  'quantity': item.quantity,
                  'upDateSpare': item.upDateSpare ? 1 : 0,
                  'updateQuantity': item.updateQuantity,
                  'price': item.price,
                  'location': item.location,
                  'spareLocationId': item.spareLocationId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ConsumedSpareRequestDataTable>
      _consumedSpareRequestDataTableInsertionAdapter;

  final DeletionAdapter<ConsumedSpareRequestDataTable>
      _consumedSpareRequestDataTableDeletionAdapter;

  @override
  Future<List<ConsumedSpareRequestDataTable>>
      findAllConsumedSpareRequestData() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ConsumedSpareRequestDataTable',
        mapper: (Map<String, Object?> row) => ConsumedSpareRequestDataTable(
            row['id'] as int,
            row['spareId'] as String,
            row['spareCode'] as String,
            row['spareName'] as String,
            row['quantity'] as int,
            (row['upDateSpare'] as int) != 0,
            row['updateQuantity'] as int,
            row['price'] as int,
            row['location'] as String,
            row['spareLocationId'] as int));
  }

  @override
  Future<ConsumedSpareRequestDataTable?> findConsumedSpareRequestDataById(
      String id) async {
    return _queryAdapter.query(
        'SELECT * FROM ConsumedSpareRequestDataTable WHERE spareId = ?1',
        mapper: (Map<String, Object?> row) => ConsumedSpareRequestDataTable(
            row['id'] as int,
            row['spareId'] as String,
            row['spareCode'] as String,
            row['spareName'] as String,
            row['quantity'] as int,
            (row['upDateSpare'] as int) != 0,
            row['updateQuantity'] as int,
            row['price'] as int,
            row['location'] as String,
            row['spareLocationId'] as int),
        arguments: [id]);
  }

  @override
  Future<List<ConsumedSpareRequestDataTable?>> updateSpareCart(
      bool updateSpare) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ConsumedSpareRequestDataTable WHERE upDateSpare = ?1',
        mapper: (Map<String, Object?> row) => ConsumedSpareRequestDataTable(
            row['id'] as int,
            row['spareId'] as String,
            row['spareCode'] as String,
            row['spareName'] as String,
            row['quantity'] as int,
            (row['upDateSpare'] as int) != 0,
            row['updateQuantity'] as int,
            row['price'] as int,
            row['location'] as String,
            row['spareLocationId'] as int),
        arguments: [updateSpare ? 1 : 0]);
  }

  @override
  Future<void> updateConsumedSpare(bool upDateSpare, String spareId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ConsumedSpareRequestDataTable SET upDateSpare = ?1 WHERE spareId =?2',
        arguments: [upDateSpare ? 1 : 0, spareId]);
  }

  @override
  Future<void> updateQuantity(int quantity, String spareId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ConsumedSpareRequestDataTable SET updateQuantity = ?1 WHERE spareId =?2',
        arguments: [quantity, spareId]);
  }

  @override
  Future<void> deleteConsumedSpareRequestDataItem(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM ConsumedSpareRequestDataTable WHERE id =?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteConsumedSpareRequestDataTable() async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM ConsumedSpareRequestDataTable');
  }

  @override
  Future<void> insertConsumedSpareRequestData(
      ConsumedSpareRequestDataTable consumedSpareRequestDataTable) async {
    await _consumedSpareRequestDataTableInsertionAdapter.insert(
        consumedSpareRequestDataTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteConsumedSpareRequestData(
      ConsumedSpareRequestDataTable consumedSpareRequestDataTable) async {
    await _consumedSpareRequestDataTableDeletionAdapter
        .delete(consumedSpareRequestDataTable);
  }
}

class _$SpareRequestDataDao extends SpareRequestDataDao {
  _$SpareRequestDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _spareRequestDataTableInsertionAdapter = InsertionAdapter(
            database,
            'SpareRequestDataTable',
            (SpareRequestDataTable item) => <String, Object?>{
                  'id': item.id,
                  'spareId': item.spareId,
                  'spareCode': item.spareCode,
                  'spareName': item.spareName,
                  'productId': item.productId,
                  'productSubId': item.productSubId,
                  'location': item.location,
                  'quantity': item.quantity,
                  'price': item.price,
                  'spareModel': item.spareModel,
                  'upDateSpare': item.upDateSpare ? 1 : 0,
                  'updateQuantity': item.updateQuantity,
                  'isChargeable': item.isChargeable,
                  'leadTime': item.leadTime,
                  'totalCost': item.totalCost,
                  'locationId': item.locationId
                }),
        _spareRequestDataTableDeletionAdapter = DeletionAdapter(
            database,
            'SpareRequestDataTable',
            ['id'],
            (SpareRequestDataTable item) => <String, Object?>{
                  'id': item.id,
                  'spareId': item.spareId,
                  'spareCode': item.spareCode,
                  'spareName': item.spareName,
                  'productId': item.productId,
                  'productSubId': item.productSubId,
                  'location': item.location,
                  'quantity': item.quantity,
                  'price': item.price,
                  'spareModel': item.spareModel,
                  'upDateSpare': item.upDateSpare ? 1 : 0,
                  'updateQuantity': item.updateQuantity,
                  'isChargeable': item.isChargeable,
                  'leadTime': item.leadTime,
                  'totalCost': item.totalCost,
                  'locationId': item.locationId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SpareRequestDataTable>
      _spareRequestDataTableInsertionAdapter;

  final DeletionAdapter<SpareRequestDataTable>
      _spareRequestDataTableDeletionAdapter;

  @override
  Future<List<SpareRequestDataTable>> findAllSpareRequestData() async {
    return _queryAdapter.queryList('SELECT * FROM SpareRequestDataTable',
        mapper: (Map<String, Object?> row) => SpareRequestDataTable(
            row['id'] as int,
            row['spareId'] as String,
            row['spareCode'] as String,
            row['spareName'] as String,
            row['productId'] as int,
            row['productSubId'] as int,
            row['location'] as String,
            row['quantity'] as int,
            row['price'] as double,
            row['spareModel'] as String,
            (row['upDateSpare'] as int) != 0,
            row['updateQuantity'] as int,
            row['isChargeable'] as int,
            row['leadTime'] as int,
            row['totalCost'] as double,
            row['locationId'] as int));
  }

  @override
  Future<SpareRequestDataTable?> findSpareRequestDataById(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM SpareRequestDataTable WHERE spareId = ?1',
        mapper: (Map<String, Object?> row) => SpareRequestDataTable(
            row['id'] as int,
            row['spareId'] as String,
            row['spareCode'] as String,
            row['spareName'] as String,
            row['productId'] as int,
            row['productSubId'] as int,
            row['location'] as String,
            row['quantity'] as int,
            row['price'] as double,
            row['spareModel'] as String,
            (row['upDateSpare'] as int) != 0,
            row['updateQuantity'] as int,
            row['isChargeable'] as int,
            row['leadTime'] as int,
            row['totalCost'] as double,
            row['locationId'] as int),
        arguments: [id]);
  }

  @override
  Future<List<SpareRequestDataTable?>> updateSpareRequestData(
      bool updateSpare) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SpareRequestDataTable WHERE upDateSpare = ?1',
        mapper: (Map<String, Object?> row) => SpareRequestDataTable(
            row['id'] as int,
            row['spareId'] as String,
            row['spareCode'] as String,
            row['spareName'] as String,
            row['productId'] as int,
            row['productSubId'] as int,
            row['location'] as String,
            row['quantity'] as int,
            row['price'] as double,
            row['spareModel'] as String,
            (row['upDateSpare'] as int) != 0,
            row['updateQuantity'] as int,
            row['isChargeable'] as int,
            row['leadTime'] as int,
            row['totalCost'] as double,
            row['locationId'] as int),
        arguments: [updateSpare ? 1 : 0]);
  }

  @override
  Future<void> updateConsumedSpare(bool upDateSpare, String spareId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE SpareRequestDataTable SET upDateSpare = ?1 WHERE spareId =?2',
        arguments: [upDateSpare ? 1 : 0, spareId]);
  }

  @override
  Future<void> updateQuantity(int quantity, String spareId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE SpareRequestDataTable SET updateQuantity = ?1 WHERE spareId =?2',
        arguments: [quantity, spareId]);
  }

  @override
  Future<void> updatespareischargeable(
      int ischargeable, double totalCost, int spareId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE SpareRequestDataTable SET isChargeable = ?1,totalCost = ?2 WHERE spareId =?3',
        arguments: [ischargeable, totalCost, spareId]);
  }

  @override
  Future<void> deleteSpareRequestDataItem(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM SpareRequestDataTable WHERE id =?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteSpareRequestDataTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM SpareRequestDataTable');
  }

  @override
  Future<void> insertSpareRequestData(
      SpareRequestDataTable spareRequestDataTable) async {
    await _spareRequestDataTableInsertionAdapter.insert(
        spareRequestDataTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSpareRequestData(
      SpareRequestDataTable spareRequestDataTable) async {
    await _spareRequestDataTableDeletionAdapter.delete(spareRequestDataTable);
  }
}

class _$InstallationReportDataDao extends InstallationReportDataDao {
  _$InstallationReportDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _installationReportDataTableInsertionAdapter = InsertionAdapter(
            database,
            'InstallationReportDataTable',
            (InstallationReportDataTable item) => <String, Object?>{
                  'id': item.id,
                  'ser_check_list_id': item.ser_check_list_id,
                  'service_group': item.service_group,
                  'description': item.description,
                  'quation_type': item.quation_type,
                  'product_id': item.product_id,
                  'answer_value': item.answer_value,
                  'remarks': item.remarks,
                  'qsatype1': item.qsatype1 ? 1 : 0,
                  'qsatype2': item.qsatype2 ? 1 : 0
                },
            changeListener),
        _installationReportDataTableDeletionAdapter = DeletionAdapter(
            database,
            'InstallationReportDataTable',
            ['id'],
            (InstallationReportDataTable item) => <String, Object?>{
                  'id': item.id,
                  'ser_check_list_id': item.ser_check_list_id,
                  'service_group': item.service_group,
                  'description': item.description,
                  'quation_type': item.quation_type,
                  'product_id': item.product_id,
                  'answer_value': item.answer_value,
                  'remarks': item.remarks,
                  'qsatype1': item.qsatype1 ? 1 : 0,
                  'qsatype2': item.qsatype2 ? 1 : 0
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<InstallationReportDataTable>
      _installationReportDataTableInsertionAdapter;

  final DeletionAdapter<InstallationReportDataTable>
      _installationReportDataTableDeletionAdapter;

  @override
  Future<List<InstallationReportDataTable>>
      findAllInstallationReportData() async {
    return _queryAdapter.queryList('SELECT * FROM InstallationReportDataTable',
        mapper: (Map<String, Object?> row) => InstallationReportDataTable(
            row['id'] as int,
            row['ser_check_list_id'] as int,
            row['service_group'] as String,
            row['description'] as String,
            row['quation_type'] as int,
            row['product_id'] as String,
            row['answer_value'] as String,
            row['remarks'] as String,
            (row['qsatype1'] as int) != 0,
            (row['qsatype2'] as int) != 0));
  }

  @override
  Stream<InstallationReportDataTable?> findTInstallationReportDataById(
      String ticketId, String id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM InstallationReportDataTable WHERE ticketId = ?1 AND id = ?2',
        mapper: (Map<String, Object?> row) => InstallationReportDataTable(
            row['id'] as int,
            row['ser_check_list_id'] as int,
            row['service_group'] as String,
            row['description'] as String,
            row['quation_type'] as int,
            row['product_id'] as String,
            row['answer_value'] as String,
            row['remarks'] as String,
            (row['qsatype1'] as int) != 0,
            (row['qsatype2'] as int) != 0),
        arguments: [ticketId, id],
        queryableName: 'InstallationReportDataTable',
        isView: false);
  }

  @override
  Future<void> updateData(
      String answerValue, String remarks, int ser_check_list_id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE InstallationReportDataTable SET answer_value = ?1,remarks = ?2 WHERE ser_check_list_id =?3',
        arguments: [answerValue, remarks, ser_check_list_id]);
  }

  @override
  Future<void> updateDataCheckBox(
      bool question1, bool question2, int ser_check_list_id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE InstallationReportDataTable SET qsatype1 =?1,qsatype2 = ?2 WHERE ser_check_list_id =?3',
        arguments: [question1 ? 1 : 0, question2 ? 1 : 0, ser_check_list_id]);
  }

  @override
  Future<void> deleteTicketForTheDayItem(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM InstallationReportDataTable WHERE id =?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteTicketForTheDayTable() async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM InstallationReportDataTable');
  }

  @override
  Future<void> insertInstallationReportData(
      InstallationReportDataTable installationReportDataTable) async {
    await _installationReportDataTableInsertionAdapter.insert(
        installationReportDataTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTInstallationReportData(
      InstallationReportDataTable installationReportDataTable) async {
    await _installationReportDataTableDeletionAdapter
        .delete(installationReportDataTable);
  }
}

class _$SearchAMCContractDataDao extends SearchAMCContractDataDao {
  _$SearchAMCContractDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _searchAMCContractDataTableInsertionAdapter = InsertionAdapter(
            database,
            'SearchAMCContractDataTable',
            (SearchAMCContractDataTable item) => <String, Object?>{
                  'id': item.id,
                  'customerCode': item.customerCode,
                  'customerName': item.customerName,
                  'emailId': item.emailId,
                  'contactNumber': item.contactNumber,
                  'contractId': item.contractId,
                  'productId': item.productId,
                  'productName': item.productName,
                  'subCategoryId': item.subCategoryId,
                  'subCategoryName': item.subCategoryName,
                  'modelNo': item.modelNo,
                  'serialNo': item.serialNo,
                  'contractType': item.contractType,
                  'plotNumber': item.plotNumber,
                  'street': item.street,
                  'postCode': item.postCode,
                  'country': item.country,
                  'state': item.state,
                  'city': item.city,
                  'location': item.location,
                  'contractDuration': item.contractDuration,
                  'contractAmmount': item.contractAmmount,
                  'startDate': item.startDate,
                  'expiryDay': item.expiryDay,
                  'invoiceId': item.invoiceId,
                  'flag': item.flag,
                  'daysLeft': item.daysLeft
                }),
        _searchAMCContractDataTableDeletionAdapter = DeletionAdapter(
            database,
            'SearchAMCContractDataTable',
            ['id'],
            (SearchAMCContractDataTable item) => <String, Object?>{
                  'id': item.id,
                  'customerCode': item.customerCode,
                  'customerName': item.customerName,
                  'emailId': item.emailId,
                  'contactNumber': item.contactNumber,
                  'contractId': item.contractId,
                  'productId': item.productId,
                  'productName': item.productName,
                  'subCategoryId': item.subCategoryId,
                  'subCategoryName': item.subCategoryName,
                  'modelNo': item.modelNo,
                  'serialNo': item.serialNo,
                  'contractType': item.contractType,
                  'plotNumber': item.plotNumber,
                  'street': item.street,
                  'postCode': item.postCode,
                  'country': item.country,
                  'state': item.state,
                  'city': item.city,
                  'location': item.location,
                  'contractDuration': item.contractDuration,
                  'contractAmmount': item.contractAmmount,
                  'startDate': item.startDate,
                  'expiryDay': item.expiryDay,
                  'invoiceId': item.invoiceId,
                  'flag': item.flag,
                  'daysLeft': item.daysLeft
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SearchAMCContractDataTable>
      _searchAMCContractDataTableInsertionAdapter;

  final DeletionAdapter<SearchAMCContractDataTable>
      _searchAMCContractDataTableDeletionAdapter;

  @override
  Future<List<SearchAMCContractDataTable>>
      findAllSearchAMCContractData() async {
    return _queryAdapter.queryList('SELECT * FROM SearchAMCContractDataTable',
        mapper: (Map<String, Object?> row) => SearchAMCContractDataTable(
            id: row['id'] as int?,
            customerCode: row['customerCode'] as String?,
            customerName: row['customerName'] as String?,
            emailId: row['emailId'] as String?,
            contactNumber: row['contactNumber'] as String?,
            contractId: row['contractId'] as int?,
            productId: row['productId'] as int?,
            productName: row['productName'] as String?,
            subCategoryId: row['subCategoryId'] as int?,
            subCategoryName: row['subCategoryName'] as String?,
            modelNo: row['modelNo'] as String?,
            serialNo: row['serialNo'] as String?,
            contractType: row['contractType'] as String?,
            plotNumber: row['plotNumber'] as String?,
            street: row['street'] as String?,
            postCode: row['postCode'] as int?,
            country: row['country'] as String?,
            state: row['state'] as String?,
            city: row['city'] as String?,
            location: row['location'] as String?,
            contractDuration: row['contractDuration'] as int?,
            contractAmmount: row['contractAmmount'] as int?,
            startDate: row['startDate'] as String?,
            expiryDay: row['expiryDay'] as String?,
            invoiceId: row['invoiceId'] as String?,
            flag: row['flag'] as int?,
            daysLeft: row['daysLeft'] as int?));
  }

  @override
  Future<List<SearchAMCContractDataTable>> findSearchAMCContractData(
      int id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SearchAMCContractDataTable WHERE id = ?1',
        mapper: (Map<String, Object?> row) => SearchAMCContractDataTable(
            id: row['id'] as int?,
            customerCode: row['customerCode'] as String?,
            customerName: row['customerName'] as String?,
            emailId: row['emailId'] as String?,
            contactNumber: row['contactNumber'] as String?,
            contractId: row['contractId'] as int?,
            productId: row['productId'] as int?,
            productName: row['productName'] as String?,
            subCategoryId: row['subCategoryId'] as int?,
            subCategoryName: row['subCategoryName'] as String?,
            modelNo: row['modelNo'] as String?,
            serialNo: row['serialNo'] as String?,
            contractType: row['contractType'] as String?,
            plotNumber: row['plotNumber'] as String?,
            street: row['street'] as String?,
            postCode: row['postCode'] as int?,
            country: row['country'] as String?,
            state: row['state'] as String?,
            city: row['city'] as String?,
            location: row['location'] as String?,
            contractDuration: row['contractDuration'] as int?,
            contractAmmount: row['contractAmmount'] as int?,
            startDate: row['startDate'] as String?,
            expiryDay: row['expiryDay'] as String?,
            invoiceId: row['invoiceId'] as String?,
            flag: row['flag'] as int?,
            daysLeft: row['daysLeft'] as int?),
        arguments: [id]);
  }

  @override
  Future<void> deleteSearchAMCContractDataTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM SearchAMCContractDataTable');
  }

  @override
  Future<void> insertSearchAMCContractData(
      SearchAMCContractDataTable installationReportDataTable) async {
    await _searchAMCContractDataTableInsertionAdapter.insert(
        installationReportDataTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSearchAMCContractData(
      SearchAMCContractDataTable installationReportDataTable) async {
    await _searchAMCContractDataTableDeletionAdapter
        .delete(installationReportDataTable);
  }
}

class _$TravelUpdateRequestDataDao extends TravelUpdateRequestDataDao {
  _$TravelUpdateRequestDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _travelUpdateRequestDataInsertionAdapter = InsertionAdapter(
            database,
            'TravelUpdateRequestData',
            (TravelUpdateRequestData item) => <String, Object?>{
                  'id': item.id,
                  'ticketId': item.ticketId,
                  'modeOfTravel': item.modeOfTravel,
                  'noOfKmTravelled': item.noOfKmTravelled,
                  'estimatedTime': item.estimatedTime,
                  'startDate': item.startDate,
                  'endDate': item.endDate,
                  'imageSelected': item.imageSelected,
                  'imagePath': item.imagePath,
                  'expenses': item.expenses,
                  'adapterPosition': item.adapterPosition
                }),
        _travelUpdateRequestDataDeletionAdapter = DeletionAdapter(
            database,
            'TravelUpdateRequestData',
            ['id'],
            (TravelUpdateRequestData item) => <String, Object?>{
                  'id': item.id,
                  'ticketId': item.ticketId,
                  'modeOfTravel': item.modeOfTravel,
                  'noOfKmTravelled': item.noOfKmTravelled,
                  'estimatedTime': item.estimatedTime,
                  'startDate': item.startDate,
                  'endDate': item.endDate,
                  'imageSelected': item.imageSelected,
                  'imagePath': item.imagePath,
                  'expenses': item.expenses,
                  'adapterPosition': item.adapterPosition
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TravelUpdateRequestData>
      _travelUpdateRequestDataInsertionAdapter;

  final DeletionAdapter<TravelUpdateRequestData>
      _travelUpdateRequestDataDeletionAdapter;

  @override
  Future<List<TravelUpdateRequestData>> findAllSearchAMCContractData() async {
    return _queryAdapter.queryList('SELECT * FROM TravelUpdateRequestData',
        mapper: (Map<String, Object?> row) => TravelUpdateRequestData(
            id: row['id'] as int?,
            ticketId: row['ticketId'] as String?,
            modeOfTravel: row['modeOfTravel'] as String?,
            noOfKmTravelled: row['noOfKmTravelled'] as String?,
            estimatedTime: row['estimatedTime'] as String?,
            startDate: row['startDate'] as String?,
            endDate: row['endDate'] as String?,
            imageSelected: row['imageSelected'] as String?,
            imagePath: row['imagePath'] as String?,
            expenses: row['expenses'] as String?,
            adapterPosition: row['adapterPosition'] as int?));
  }

  @override
  Future<void> deleteSearchAMCContractDataTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM TravelUpdateRequestData');
  }

  @override
  Future<void> insertSearchAMCContractData(
      TravelUpdateRequestData travelUpdateRequestData) async {
    await _travelUpdateRequestDataInsertionAdapter.insert(
        travelUpdateRequestData, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSearchAMCContractData(
      TravelUpdateRequestData travelUpdateRequestData) async {
    await _travelUpdateRequestDataDeletionAdapter
        .delete(travelUpdateRequestData);
  }
}

class _$SerialNoDataDao extends SerialNoDataDao {
  _$SerialNoDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _serialNoDataTableInsertionAdapter = InsertionAdapter(
            database,
            'SerialNoDataTable',
            (SerialNoDataTable item) => <String, Object?>{
                  'id': item.id,
                  'serialNo': item.serialNo,
                  'ticketId': item.ticketId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SerialNoDataTable> _serialNoDataTableInsertionAdapter;

  @override
  Future<List<SerialNoDataTable>> findAllSerialNoData() async {
    return _queryAdapter.queryList('SELECT * FROM SerialNoDataTable',
        mapper: (Map<String, Object?> row) => SerialNoDataTable(
            row['id'] as int,
            row['serialNo'] as String,
            row['ticketId'] as String));
  }

  @override
  Future<List<SerialNoDataTable>> findSerialNoDataByTicketId(
      String ticketId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SerialNoDataTable WHERE ticketId = ?1',
        mapper: (Map<String, Object?> row) => SerialNoDataTable(
            row['id'] as int,
            row['serialNo'] as String,
            row['ticketId'] as String),
        arguments: [ticketId]);
  }

  @override
  Future<void> deleteSerialNoData() async {
    await _queryAdapter.queryNoReturn('DELETE FROM SerialNoDataTable');
  }

  @override
  Future<void> insertSerialNoData(
      SerialNoDataTable installationReportDataTable) async {
    await _serialNoDataTableInsertionAdapter.insert(
        installationReportDataTable, OnConflictStrategy.abort);
  }
}

class _$NewAMCCreationDataDao extends NewAMCCreationDataDao {
  _$NewAMCCreationDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _newAMCCreationDataTableInsertionAdapter = InsertionAdapter(
            database,
            'NewAMCCreationDataTable',
            (NewAMCCreationDataTable item) => <String, Object?>{
                  'id': item.id,
                  'contactNumber': item.contactNumber,
                  'customerName': item.customerName,
                  'customerEmail': item.customerEmail,
                  'flatNoStreet': item.flatNoStreet,
                  'street': item.street,
                  'postCode': item.postCode,
                  'countryId': item.countryId,
                  'stateId': item.stateId,
                  'cityId': item.cityId,
                  'locationId': item.locationId,
                  'priority': item.priority,
                  'amcTypeId': item.amcTypeId,
                  'amcPeriod': item.amcPeriod,
                  'startDate': item.startDate,
                  'productId': item.productId,
                  'subCategoryId': item.subCategoryId,
                  'callCategoryId': item.callCategoryId,
                  'modelNo': item.modelNo,
                  'invoiceNo': item.invoiceNo,
                  'totalAmount': item.totalAmount,
                  'modeOfPayment': item.modeOfPayment,
                  'checkable':
                      item.checkable == null ? null : (item.checkable! ? 1 : 0),
                  'customerCode': item.customerCode
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NewAMCCreationDataTable>
      _newAMCCreationDataTableInsertionAdapter;

  @override
  Future<List<NewAMCCreationDataTable>> findAllNewAMCCreationData() async {
    return _queryAdapter.queryList('SELECT * FROM NewAMCCreationDataTable',
        mapper: (Map<String, Object?> row) => NewAMCCreationDataTable(
            id: row['id'] as int?,
            contactNumber: row['contactNumber'] as String?,
            customerName: row['customerName'] as String?,
            customerEmail: row['customerEmail'] as String?,
            flatNoStreet: row['flatNoStreet'] as String?,
            street: row['street'] as String?,
            postCode: row['postCode'] as int?,
            countryId: row['countryId'] as int?,
            stateId: row['stateId'] as int?,
            cityId: row['cityId'] as int?,
            locationId: row['locationId'] as int?,
            priority: row['priority'] as String?,
            amcTypeId: row['amcTypeId'] as int?,
            amcPeriod: row['amcPeriod'] as int?,
            startDate: row['startDate'] as String?,
            productId: row['productId'] as int?,
            subCategoryId: row['subCategoryId'] as int?,
            callCategoryId: row['callCategoryId'] as int?,
            modelNo: row['modelNo'] as String?,
            invoiceNo: row['invoiceNo'] as String?,
            totalAmount: row['totalAmount'] as int?,
            modeOfPayment: row['modeOfPayment'] as String?,
            checkable: row['checkable'] == null
                ? null
                : (row['checkable'] as int) != 0,
            customerCode: row['customerCode'] as String?));
  }

  @override
  Future<List<NewAMCCreationDataTable>> findNewAMCCreationDataByCheckable(
      bool checkable) async {
    return _queryAdapter.queryList(
        'SELECT * FROM NewAMCCreationDataTable WHERE checkable = ?1',
        mapper: (Map<String, Object?> row) => NewAMCCreationDataTable(
            id: row['id'] as int?,
            contactNumber: row['contactNumber'] as String?,
            customerName: row['customerName'] as String?,
            customerEmail: row['customerEmail'] as String?,
            flatNoStreet: row['flatNoStreet'] as String?,
            street: row['street'] as String?,
            postCode: row['postCode'] as int?,
            countryId: row['countryId'] as int?,
            stateId: row['stateId'] as int?,
            cityId: row['cityId'] as int?,
            locationId: row['locationId'] as int?,
            priority: row['priority'] as String?,
            amcTypeId: row['amcTypeId'] as int?,
            amcPeriod: row['amcPeriod'] as int?,
            startDate: row['startDate'] as String?,
            productId: row['productId'] as int?,
            subCategoryId: row['subCategoryId'] as int?,
            callCategoryId: row['callCategoryId'] as int?,
            modelNo: row['modelNo'] as String?,
            invoiceNo: row['invoiceNo'] as String?,
            totalAmount: row['totalAmount'] as int?,
            modeOfPayment: row['modeOfPayment'] as String?,
            checkable: row['checkable'] == null
                ? null
                : (row['checkable'] as int) != 0,
            customerCode: row['customerCode'] as String?),
        arguments: [checkable ? 1 : 0]);
  }

  @override
  Future<void> deleteNewAMCCreationData() async {
    await _queryAdapter.queryNoReturn('DELETE FROM NewAMCCreationDataTable');
  }

  @override
  Future<void> insertNewAMCCreationData(
      NewAMCCreationDataTable newAMCCreationDataTable) async {
    await _newAMCCreationDataTableInsertionAdapter.insert(
        newAMCCreationDataTable, OnConflictStrategy.abort);
  }
}

class _$AssessmentQuestionDataDao extends AssessmentQuestionDataDao {
  _$AssessmentQuestionDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _assessmentQuestionDataTableInsertionAdapter = InsertionAdapter(
            database,
            'AssessmentQuestionDataTable',
            (AssessmentQuestionDataTable item) => <String, Object?>{
                  'id': item.id,
                  'assessmentId': item.assessmentId,
                  'assessmentName': item.assessmentName,
                  'totalQuations': item.totalQuations,
                  'quationToAssessment': item.quationToAssessment,
                  'score': item.score,
                  'status': item.status,
                  'trainingId': item.trainingId,
                  'threshold': item.threshold,
                  'assessment_status': item.assessment_status == null
                      ? null
                      : (item.assessment_status! ? 1 : 0)
                }),
        _assessmentQuestionDataTableDeletionAdapter = DeletionAdapter(
            database,
            'AssessmentQuestionDataTable',
            ['id'],
            (AssessmentQuestionDataTable item) => <String, Object?>{
                  'id': item.id,
                  'assessmentId': item.assessmentId,
                  'assessmentName': item.assessmentName,
                  'totalQuations': item.totalQuations,
                  'quationToAssessment': item.quationToAssessment,
                  'score': item.score,
                  'status': item.status,
                  'trainingId': item.trainingId,
                  'threshold': item.threshold,
                  'assessment_status': item.assessment_status == null
                      ? null
                      : (item.assessment_status! ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AssessmentQuestionDataTable>
      _assessmentQuestionDataTableInsertionAdapter;

  final DeletionAdapter<AssessmentQuestionDataTable>
      _assessmentQuestionDataTableDeletionAdapter;

  @override
  Future<List<AssessmentQuestionDataTable>>
      findAllAssessmentQuestionData() async {
    return _queryAdapter.queryList('SELECT * FROM AssessmentQuestionDataTable',
        mapper: (Map<String, Object?> row) => AssessmentQuestionDataTable(
            id: row['id'] as int?,
            assessmentId: row['assessmentId'] as int?,
            assessmentName: row['assessmentName'] as String?,
            totalQuations: row['totalQuations'] as int?,
            quationToAssessment: row['quationToAssessment'] as int?,
            score: row['score'] as int?,
            status: row['status'] as String?,
            trainingId: row['trainingId'] as String?,
            threshold: row['threshold'] as int?,
            assessment_status: row['assessment_status'] == null
                ? null
                : (row['assessment_status'] as int) != 0));
  }

  @override
  Future<List<AssessmentQuestionDataTable>>
      findAssessmentQuestionDataByAssessmentId(int assessmentId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM AssessmentQuestionDataTable WHERE assessmentId = ?1',
        mapper: (Map<String, Object?> row) => AssessmentQuestionDataTable(
            id: row['id'] as int?,
            assessmentId: row['assessmentId'] as int?,
            assessmentName: row['assessmentName'] as String?,
            totalQuations: row['totalQuations'] as int?,
            quationToAssessment: row['quationToAssessment'] as int?,
            score: row['score'] as int?,
            status: row['status'] as String?,
            trainingId: row['trainingId'] as String?,
            threshold: row['threshold'] as int?,
            assessment_status: row['assessment_status'] == null
                ? null
                : (row['assessment_status'] as int) != 0),
        arguments: [assessmentId]);
  }

  @override
  Future<List<AssessmentQuestionDataTable>>
      findAssessmentQuestionDataByAssessmentStatus(
          bool assessment_status) async {
    return _queryAdapter.queryList(
        'SELECT * FROM AssessmentQuestionDataTable WHERE assessment_status = ?1',
        mapper: (Map<String, Object?> row) => AssessmentQuestionDataTable(id: row['id'] as int?, assessmentId: row['assessmentId'] as int?, assessmentName: row['assessmentName'] as String?, totalQuations: row['totalQuations'] as int?, quationToAssessment: row['quationToAssessment'] as int?, score: row['score'] as int?, status: row['status'] as String?, trainingId: row['trainingId'] as String?, threshold: row['threshold'] as int?, assessment_status: row['assessment_status'] == null ? null : (row['assessment_status'] as int) != 0),
        arguments: [assessment_status ? 1 : 0]);
  }

  @override
  Future<void> updateAssessmentQuestionDataByAssessmentStatusAndAssessmentId(
      bool assessment_status, int assessmentId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE AssessmentQuestionDataTable SET assessment_status = ?1 WHERE assessmentId =?2',
        arguments: [assessment_status ? 1 : 0, assessmentId]);
  }

  @override
  Future<void> deleteAssessmentQuestionDataTable() async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM AssessmentQuestionDataTable');
  }

  @override
  Future<void> insertAssessmentQuestionData(
      AssessmentQuestionDataTable assessmentQuestionDataTable) async {
    await _assessmentQuestionDataTableInsertionAdapter.insert(
        assessmentQuestionDataTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAssessmentQuestionData(
      AssessmentQuestionDataTable assessmentQuestionDataTable) async {
    await _assessmentQuestionDataTableDeletionAdapter
        .delete(assessmentQuestionDataTable);
  }
}

class _$AssessmentQuizDataDao extends AssessmentQuizDataDao {
  _$AssessmentQuizDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _assessmentQuizDataTableInsertionAdapter = InsertionAdapter(
            database,
            'AssessmentQuizDataTable',
            (AssessmentQuizDataTable item) => <String, Object?>{
                  'id': item.id,
                  'quationId': item.quationId,
                  'assessment_id': item.assessment_id,
                  'quation': item.quation,
                  'optionA': item.optionA,
                  'optionB': item.optionB,
                  'optionC': item.optionC,
                  'optionD': item.optionD,
                  'correctAnswer': item.correctAnswer,
                  'updateAnswer_a': item.updateAnswer_a == null
                      ? null
                      : (item.updateAnswer_a! ? 1 : 0),
                  'updateAnswer_b': item.updateAnswer_b == null
                      ? null
                      : (item.updateAnswer_b! ? 1 : 0),
                  'updateAnswer_c': item.updateAnswer_c == null
                      ? null
                      : (item.updateAnswer_c! ? 1 : 0),
                  'updateAnswer_d': item.updateAnswer_d == null
                      ? null
                      : (item.updateAnswer_d! ? 1 : 0),
                  'your_answer': item.your_answer
                }),
        _assessmentQuizDataTableDeletionAdapter = DeletionAdapter(
            database,
            'AssessmentQuizDataTable',
            ['id'],
            (AssessmentQuizDataTable item) => <String, Object?>{
                  'id': item.id,
                  'quationId': item.quationId,
                  'assessment_id': item.assessment_id,
                  'quation': item.quation,
                  'optionA': item.optionA,
                  'optionB': item.optionB,
                  'optionC': item.optionC,
                  'optionD': item.optionD,
                  'correctAnswer': item.correctAnswer,
                  'updateAnswer_a': item.updateAnswer_a == null
                      ? null
                      : (item.updateAnswer_a! ? 1 : 0),
                  'updateAnswer_b': item.updateAnswer_b == null
                      ? null
                      : (item.updateAnswer_b! ? 1 : 0),
                  'updateAnswer_c': item.updateAnswer_c == null
                      ? null
                      : (item.updateAnswer_c! ? 1 : 0),
                  'updateAnswer_d': item.updateAnswer_d == null
                      ? null
                      : (item.updateAnswer_d! ? 1 : 0),
                  'your_answer': item.your_answer
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AssessmentQuizDataTable>
      _assessmentQuizDataTableInsertionAdapter;

  final DeletionAdapter<AssessmentQuizDataTable>
      _assessmentQuizDataTableDeletionAdapter;

  @override
  Future<List<AssessmentQuizDataTable>> findAllAssessmentQuizData() async {
    return _queryAdapter.queryList('SELECT * FROM AssessmentQuizDataTable',
        mapper: (Map<String, Object?> row) => AssessmentQuizDataTable(
            id: row['id'] as int?,
            quationId: row['quationId'] as int?,
            assessment_id: row['assessment_id'] as int?,
            quation: row['quation'] as String?,
            optionA: row['optionA'] as String?,
            optionB: row['optionB'] as String?,
            optionC: row['optionC'] as String?,
            optionD: row['optionD'] as String?,
            correctAnswer: row['correctAnswer'] as String?,
            updateAnswer_a: row['updateAnswer_a'] == null
                ? null
                : (row['updateAnswer_a'] as int) != 0,
            updateAnswer_b: row['updateAnswer_b'] == null
                ? null
                : (row['updateAnswer_b'] as int) != 0,
            updateAnswer_c: row['updateAnswer_c'] == null
                ? null
                : (row['updateAnswer_c'] as int) != 0,
            updateAnswer_d: row['updateAnswer_d'] == null
                ? null
                : (row['updateAnswer_d'] as int) != 0,
            your_answer: row['your_answer'] as String?));
  }

  @override
  Future<List<AssessmentQuizDataTable>> findAssessmentQuizDataByAssessmentId(
      int assessment_id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM AssessmentQuizDataTable WHERE assessment_id = ?1',
        mapper: (Map<String, Object?> row) => AssessmentQuizDataTable(
            id: row['id'] as int?,
            quationId: row['quationId'] as int?,
            assessment_id: row['assessment_id'] as int?,
            quation: row['quation'] as String?,
            optionA: row['optionA'] as String?,
            optionB: row['optionB'] as String?,
            optionC: row['optionC'] as String?,
            optionD: row['optionD'] as String?,
            correctAnswer: row['correctAnswer'] as String?,
            updateAnswer_a: row['updateAnswer_a'] == null
                ? null
                : (row['updateAnswer_a'] as int) != 0,
            updateAnswer_b: row['updateAnswer_b'] == null
                ? null
                : (row['updateAnswer_b'] as int) != 0,
            updateAnswer_c: row['updateAnswer_c'] == null
                ? null
                : (row['updateAnswer_c'] as int) != 0,
            updateAnswer_d: row['updateAnswer_d'] == null
                ? null
                : (row['updateAnswer_d'] as int) != 0,
            your_answer: row['your_answer'] as String?),
        arguments: [assessment_id]);
  }

  @override
  Future<List<AssessmentQuizDataTable>> findAssessmentQuizDataByQuationId(
      int quationId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM AssessmentQuizDataTable WHERE quationId = ?1',
        mapper: (Map<String, Object?> row) => AssessmentQuizDataTable(
            id: row['id'] as int?,
            quationId: row['quationId'] as int?,
            assessment_id: row['assessment_id'] as int?,
            quation: row['quation'] as String?,
            optionA: row['optionA'] as String?,
            optionB: row['optionB'] as String?,
            optionC: row['optionC'] as String?,
            optionD: row['optionD'] as String?,
            correctAnswer: row['correctAnswer'] as String?,
            updateAnswer_a: row['updateAnswer_a'] == null
                ? null
                : (row['updateAnswer_a'] as int) != 0,
            updateAnswer_b: row['updateAnswer_b'] == null
                ? null
                : (row['updateAnswer_b'] as int) != 0,
            updateAnswer_c: row['updateAnswer_c'] == null
                ? null
                : (row['updateAnswer_c'] as int) != 0,
            updateAnswer_d: row['updateAnswer_d'] == null
                ? null
                : (row['updateAnswer_d'] as int) != 0,
            your_answer: row['your_answer'] as String?),
        arguments: [quationId]);
  }

  @override
  Future<void> updateAssessmentQuizDataByYourAnswerANDQuationId(
      String your_answer, int quationId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE AssessmentQuizDataTable SET your_answer = ?1 WHERE quationId =?2',
        arguments: [your_answer, quationId]);
  }

  @override
  Future<void> updatessessmentQuizData(bool updateAnswer_a, bool updateAnswer_b,
      bool updateAnswer_c, bool updateAnswer_d, int quationId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE AssessmentQuizDataTable SET updateAnswer_a = ?1, updateAnswer_b = ?2 , updateAnswer_c = ?3 , updateAnswer_d = ?4 WHERE quationId =?5',
        arguments: [
          updateAnswer_a ? 1 : 0,
          updateAnswer_b ? 1 : 0,
          updateAnswer_c ? 1 : 0,
          updateAnswer_d ? 1 : 0,
          quationId
        ]);
  }

  @override
  Future<void> deleteAssessmentQuizDataTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM AssessmentQuizDataTable');
  }

  @override
  Future<void> insertAssessmentQuizData(
      AssessmentQuizDataTable assessmentQuizDataTable) async {
    await _assessmentQuizDataTableInsertionAdapter.insert(
        assessmentQuizDataTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAssessmentQuizData(
      AssessmentQuizDataTable assessmentQuizDataTable) async {
    await _assessmentQuizDataTableDeletionAdapter
        .delete(assessmentQuizDataTable);
  }
}

class _$TrainingListDataDao extends TrainingListDataDao {
  _$TrainingListDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _trainingListDataTableInsertionAdapter = InsertionAdapter(
            database,
            'TrainingListDataTable',
            (TrainingListDataTable item) => <String, Object?>{
                  'id': item.id,
                  'training_id': item.training_id,
                  'training_title': item.training_title,
                  'certificate_id': item.certificate_id,
                  'training_thumb_image': item.training_thumb_image,
                  'training_content_type': item.training_content_type,
                  'training_content': item.training_content,
                  'trainingPdfImage': item.trainingPdfImage,
                  'trainingVideoImage': item.trainingVideoImage,
                  'trainingWordImage': item.trainingWordImage,
                  'trainingLinkImage': item.trainingLinkImage,
                  'pdfCount':
                      item.pdfCount == null ? null : (item.pdfCount! ? 1 : 0),
                  'videoCount': item.videoCount == null
                      ? null
                      : (item.videoCount! ? 1 : 0),
                  'wordCount':
                      item.wordCount == null ? null : (item.wordCount! ? 1 : 0),
                  'linkCount':
                      item.linkCount == null ? null : (item.linkCount! ? 1 : 0),
                  'assessment_id': item.assessment_id
                }),
        _trainingListDataTableDeletionAdapter = DeletionAdapter(
            database,
            'TrainingListDataTable',
            ['id'],
            (TrainingListDataTable item) => <String, Object?>{
                  'id': item.id,
                  'training_id': item.training_id,
                  'training_title': item.training_title,
                  'certificate_id': item.certificate_id,
                  'training_thumb_image': item.training_thumb_image,
                  'training_content_type': item.training_content_type,
                  'training_content': item.training_content,
                  'trainingPdfImage': item.trainingPdfImage,
                  'trainingVideoImage': item.trainingVideoImage,
                  'trainingWordImage': item.trainingWordImage,
                  'trainingLinkImage': item.trainingLinkImage,
                  'pdfCount':
                      item.pdfCount == null ? null : (item.pdfCount! ? 1 : 0),
                  'videoCount': item.videoCount == null
                      ? null
                      : (item.videoCount! ? 1 : 0),
                  'wordCount':
                      item.wordCount == null ? null : (item.wordCount! ? 1 : 0),
                  'linkCount':
                      item.linkCount == null ? null : (item.linkCount! ? 1 : 0),
                  'assessment_id': item.assessment_id
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TrainingListDataTable>
      _trainingListDataTableInsertionAdapter;

  final DeletionAdapter<TrainingListDataTable>
      _trainingListDataTableDeletionAdapter;

  @override
  Future<List<TrainingListDataTable>> findAllTrainingListData() async {
    return _queryAdapter.queryList('SELECT * FROM TrainingListDataTable',
        mapper: (Map<String, Object?> row) => TrainingListDataTable(
            id: row['id'] as int?,
            training_id: row['training_id'] as String?,
            training_title: row['training_title'] as String?,
            certificate_id: row['certificate_id'] as String?,
            training_thumb_image: row['training_thumb_image'] as String?,
            training_content_type: row['training_content_type'] as String?,
            training_content: row['training_content'] as String?,
            trainingPdfImage: row['trainingPdfImage'] as String?,
            trainingVideoImage: row['trainingVideoImage'] as String?,
            trainingWordImage: row['trainingWordImage'] as String?,
            trainingLinkImage: row['trainingLinkImage'] as String?,
            pdfCount:
                row['pdfCount'] == null ? null : (row['pdfCount'] as int) != 0,
            videoCount: row['videoCount'] == null
                ? null
                : (row['videoCount'] as int) != 0,
            wordCount: row['wordCount'] == null
                ? null
                : (row['wordCount'] as int) != 0,
            linkCount: row['linkCount'] == null
                ? null
                : (row['linkCount'] as int) != 0,
            assessment_id: row['assessment_id'] as int?));
  }

  @override
  Future<List<TrainingListDataTable>> findTrainingListDataByTrainingId(
      String training_id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TrainingListDataTable WHERE training_id = ?1',
        mapper: (Map<String, Object?> row) => TrainingListDataTable(
            id: row['id'] as int?,
            training_id: row['training_id'] as String?,
            training_title: row['training_title'] as String?,
            certificate_id: row['certificate_id'] as String?,
            training_thumb_image: row['training_thumb_image'] as String?,
            training_content_type: row['training_content_type'] as String?,
            training_content: row['training_content'] as String?,
            trainingPdfImage: row['trainingPdfImage'] as String?,
            trainingVideoImage: row['trainingVideoImage'] as String?,
            trainingWordImage: row['trainingWordImage'] as String?,
            trainingLinkImage: row['trainingLinkImage'] as String?,
            pdfCount:
                row['pdfCount'] == null ? null : (row['pdfCount'] as int) != 0,
            videoCount: row['videoCount'] == null
                ? null
                : (row['videoCount'] as int) != 0,
            wordCount: row['wordCount'] == null
                ? null
                : (row['wordCount'] as int) != 0,
            linkCount: row['linkCount'] == null
                ? null
                : (row['linkCount'] as int) != 0,
            assessment_id: row['assessment_id'] as int?),
        arguments: [training_id]);
  }

  @override
  Future<List<TrainingListDataTable>>
      findTrainingListDataByTrainingIdAndTrainingContentType(
          String training_id, String training_content_type) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TrainingListData WHERE training_id = ?1 AND training_content_type = ?2',
        mapper: (Map<String, Object?> row) => TrainingListDataTable(id: row['id'] as int?, training_id: row['training_id'] as String?, training_title: row['training_title'] as String?, certificate_id: row['certificate_id'] as String?, training_thumb_image: row['training_thumb_image'] as String?, training_content_type: row['training_content_type'] as String?, training_content: row['training_content'] as String?, trainingPdfImage: row['trainingPdfImage'] as String?, trainingVideoImage: row['trainingVideoImage'] as String?, trainingWordImage: row['trainingWordImage'] as String?, trainingLinkImage: row['trainingLinkImage'] as String?, pdfCount: row['pdfCount'] == null ? null : (row['pdfCount'] as int) != 0, videoCount: row['videoCount'] == null ? null : (row['videoCount'] as int) != 0, wordCount: row['wordCount'] == null ? null : (row['wordCount'] as int) != 0, linkCount: row['linkCount'] == null ? null : (row['linkCount'] as int) != 0, assessment_id: row['assessment_id'] as int?),
        arguments: [training_id, training_content_type]);
  }

  @override
  Future<List<TrainingListDataTable>> findTrainingListDataByAssessmentId(
      int assessment_id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TrainingListDataTable WHERE assessment_id = ?1',
        mapper: (Map<String, Object?> row) => TrainingListDataTable(
            id: row['id'] as int?,
            training_id: row['training_id'] as String?,
            training_title: row['training_title'] as String?,
            certificate_id: row['certificate_id'] as String?,
            training_thumb_image: row['training_thumb_image'] as String?,
            training_content_type: row['training_content_type'] as String?,
            training_content: row['training_content'] as String?,
            trainingPdfImage: row['trainingPdfImage'] as String?,
            trainingVideoImage: row['trainingVideoImage'] as String?,
            trainingWordImage: row['trainingWordImage'] as String?,
            trainingLinkImage: row['trainingLinkImage'] as String?,
            pdfCount:
                row['pdfCount'] == null ? null : (row['pdfCount'] as int) != 0,
            videoCount: row['videoCount'] == null
                ? null
                : (row['videoCount'] as int) != 0,
            wordCount: row['wordCount'] == null
                ? null
                : (row['wordCount'] as int) != 0,
            linkCount: row['linkCount'] == null
                ? null
                : (row['linkCount'] as int) != 0,
            assessment_id: row['assessment_id'] as int?),
        arguments: [assessment_id]);
  }

  @override
  Future<void> deleteTrainingListDataTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM TrainingListDataTable');
  }

  @override
  Future<void> insertTrainingListData(
      TrainingListDataTable trainingListDataTable) async {
    await _trainingListDataTableInsertionAdapter.insert(
        trainingListDataTable, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTrainingListData(
      TrainingListDataTable trainingListDataTable) async {
    await _trainingListDataTableDeletionAdapter.delete(trainingListDataTable);
  }
}

class _$SmartScheduleDataDao extends SmartScheduleDataDao {
  _$SmartScheduleDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _smartScheduleDataTableInsertionAdapter = InsertionAdapter(
            database,
            'SmartScheduleDataTable',
            (SmartScheduleDataTable item) => <String, Object?>{
                  'id': item.id,
                  'smartschedule_id': item.smartschedule_id,
                  'smartschedule_date': item.smartschedule_date,
                  'smartschedule_time': item.smartschedule_time,
                  'smartschedule_tittle': item.smartschedule_tittle,
                  'smartschedule_desc': item.smartschedule_desc,
                  'smartschedule_update': item.smartschedule_update == null
                      ? null
                      : (item.smartschedule_update! ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SmartScheduleDataTable>
      _smartScheduleDataTableInsertionAdapter;

  @override
  Future<List<SmartScheduleDataTable>> findAllSmartScheduleData() async {
    return _queryAdapter.queryList('SELECT * FROM SmartScheduleDataTable',
        mapper: (Map<String, Object?> row) => SmartScheduleDataTable(
            id: row['id'] as int?,
            smartschedule_id: row['smartschedule_id'] as int?,
            smartschedule_date: row['smartschedule_date'] as String?,
            smartschedule_time: row['smartschedule_time'] as String?,
            smartschedule_tittle: row['smartschedule_tittle'] as String?,
            smartschedule_desc: row['smartschedule_desc'] as String?,
            smartschedule_update: row['smartschedule_update'] == null
                ? null
                : (row['smartschedule_update'] as int) != 0));
  }

  @override
  Future<List<SmartScheduleDataTable>> findSmartScheduleDataByDate(
      String smartschedule_date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SmartScheduleDataTable WHERE smartschedule_date = ?1',
        mapper: (Map<String, Object?> row) => SmartScheduleDataTable(
            id: row['id'] as int?,
            smartschedule_id: row['smartschedule_id'] as int?,
            smartschedule_date: row['smartschedule_date'] as String?,
            smartschedule_time: row['smartschedule_time'] as String?,
            smartschedule_tittle: row['smartschedule_tittle'] as String?,
            smartschedule_desc: row['smartschedule_desc'] as String?,
            smartschedule_update: row['smartschedule_update'] == null
                ? null
                : (row['smartschedule_update'] as int) != 0),
        arguments: [smartschedule_date]);
  }

  @override
  Future<List<SmartScheduleDataTable>> findSmartScheduleDataByDateOrTime(
      String smartschedule_date, String smartschedule_time) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SmartScheduleDataTable WHERE smartschedule_date = ?1 OR smartschedule_time = ?2',
        mapper: (Map<String, Object?> row) => SmartScheduleDataTable(id: row['id'] as int?, smartschedule_id: row['smartschedule_id'] as int?, smartschedule_date: row['smartschedule_date'] as String?, smartschedule_time: row['smartschedule_time'] as String?, smartschedule_tittle: row['smartschedule_tittle'] as String?, smartschedule_desc: row['smartschedule_desc'] as String?, smartschedule_update: row['smartschedule_update'] == null ? null : (row['smartschedule_update'] as int) != 0),
        arguments: [smartschedule_date, smartschedule_time]);
  }

  @override
  Future<void> updateSmartScheduleData(
      String smartschedule_tittle,
      String smartschedule_time,
      String smartschedule_desc,
      int smartschedule_id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE SmartScheduleDataTable SET smartschedule_tittle = ?1, smartschedule_time = ?2, smartschedule_desc = ?3 WHERE smartschedule_id =?4',
        arguments: [
          smartschedule_tittle,
          smartschedule_time,
          smartschedule_desc,
          smartschedule_id
        ]);
  }

  @override
  Future<void> deleteSmartScheduleDataTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM SmartScheduleDataTable');
  }

  @override
  Future<void> deleteSmartScheduleData(int smartschedule_id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM SmartScheduleDataTable WHERE smartschedule_id = ?1',
        arguments: [smartschedule_id]);
  }

  @override
  Future<void> insertSmartScheduleData(
      SmartScheduleDataTable smartScheduleDataTable) async {
    await _smartScheduleDataTableInsertionAdapter.insert(
        smartScheduleDataTable, OnConflictStrategy.abort);
  }
}

class _$DirectionDetailsDao extends DirectionDetailsDao {
  _$DirectionDetailsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _directionDetailsTableInsertionAdapter = InsertionAdapter(
            database,
            'DirectionDetailsTable',
            (DirectionDetailsTable item) => <String, Object?>{
                  'id': item.id,
                  'distance': item.distance,
                  'duration': item.duration,
                  'startAddress': item.startAddress,
                  'endAddress': item.endAddress,
                  'ticketId': item.ticketId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DirectionDetailsTable>
      _directionDetailsTableInsertionAdapter;

  @override
  Future<List<DirectionDetailsTable>> findAllDirectionDetailsTable() async {
    return _queryAdapter.queryList('SELECT * FROM DirectionDetailsTable',
        mapper: (Map<String, Object?> row) => DirectionDetailsTable(
            id: row['id'] as int?,
            ticketId: row['ticketId'] as String?,
            distance: row['distance'] as String?,
            duration: row['duration'] as String?,
            startAddress: row['startAddress'] as String?,
            endAddress: row['endAddress'] as String?));
  }

  @override
  Future<List<DirectionDetailsTable>> findDirectionDetailsTableByTicketId(
      String ticketId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM DirectionDetailsTable WHERE ticketId = ?1',
        mapper: (Map<String, Object?> row) => DirectionDetailsTable(
            id: row['id'] as int?,
            ticketId: row['ticketId'] as String?,
            distance: row['distance'] as String?,
            duration: row['duration'] as String?,
            startAddress: row['startAddress'] as String?,
            endAddress: row['endAddress'] as String?),
        arguments: [ticketId]);
  }

  @override
  Future<void> deleteDirectionDetailsTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM DirectionDetailsTable');
  }

  @override
  Future<void> insertDirectionDetailsTable(
      DirectionDetailsTable directionDetailsTable) async {
    await _directionDetailsTableInsertionAdapter.insert(
        directionDetailsTable, OnConflictStrategy.abort);
  }
}

class _$SelectedOnHandSpareDao extends SelectedOnHandSpareDao {
  _$SelectedOnHandSpareDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _selectedOnHandSpareDataTableInsertionAdapter = InsertionAdapter(
            database,
            'SelectedOnHandSpareDataTable',
            (SelectedOnHandSpareDataTable item) => <String, Object?>{
                  'id': item.id,
                  'spareId': item.spareId,
                  'spareCode': item.spareCode,
                  'spareName': item.spareName,
                  'quantity': item.quantity,
                  'location': item.location,
                  'isSelectedSpare': item.isSelectedSpare == null
                      ? null
                      : (item.isSelectedSpare! ? 1 : 0),
                  'locationId': item.locationId,
                  'ticketId': item.ticketId,
                  'price': item.price
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SelectedOnHandSpareDataTable>
      _selectedOnHandSpareDataTableInsertionAdapter;

  @override
  Future<List<SelectedOnHandSpareDataTable>> findAll() async {
    return _queryAdapter.queryList('SELECT * FROM SelectedOnHandSpareDataTable',
        mapper: (Map<String, Object?> row) => SelectedOnHandSpareDataTable(
            id: row['id'] as int?,
            spareId: row['spareId'] as String?,
            spareCode: row['spareCode'] as String?,
            spareName: row['spareName'] as String?,
            quantity: row['quantity'] as int?,
            location: row['location'] as String?,
            isSelectedSpare: row['isSelectedSpare'] == null
                ? null
                : (row['isSelectedSpare'] as int) != 0,
            locationId: row['locationId'] as int?,
            ticketId: row['ticketId'] as String?,
            price: row['price'] as double?));
  }

  @override
  Future<List<SelectedOnHandSpareDataTable>> getSelectedSpareByTicketId(
      bool isSelectedSpare, String ticketId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SelectedOnHandSpareDataTable WHERE isSelectedSpare =?1 AND ticketId =?2',
        mapper: (Map<String, Object?> row) => SelectedOnHandSpareDataTable(id: row['id'] as int?, spareId: row['spareId'] as String?, spareCode: row['spareCode'] as String?, spareName: row['spareName'] as String?, quantity: row['quantity'] as int?, location: row['location'] as String?, isSelectedSpare: row['isSelectedSpare'] == null ? null : (row['isSelectedSpare'] as int) != 0, locationId: row['locationId'] as int?, ticketId: row['ticketId'] as String?, price: row['price'] as double?),
        arguments: [isSelectedSpare ? 1 : 0, ticketId]);
  }

  @override
  Future<void> deleteSelectedSpareByTicketId(
      bool isSelectedSpare, String ticketId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM SelectedOnHandSpareDataTable WHERE isSelectedSpare =?1 AND ticketId =?2',
        arguments: [isSelectedSpare ? 1 : 0, ticketId]);
  }

  @override
  Future<void> insertSpare(
      SelectedOnHandSpareDataTable selectedOnHandSpareDataTable) async {
    await _selectedOnHandSpareDataTableInsertionAdapter.insert(
        selectedOnHandSpareDataTable, OnConflictStrategy.abort);
  }
}
