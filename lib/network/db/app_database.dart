import 'dart:async';

import 'package:fieldpro_genworks_healthcare/network/db/search_amc_contract_data.dart';
import 'package:fieldpro_genworks_healthcare/network/db/search_amc_contract_data_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/selected_onhand_spare.dart';
import 'package:fieldpro_genworks_healthcare/network/db/selected_onhand_spare_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/serial_no_data.dart';
import 'package:fieldpro_genworks_healthcare/network/db/serial_no_data_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/smart_schedule_data.dart';
import 'package:fieldpro_genworks_healthcare/network/db/smart_schedule_data_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/spare_request_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/spare_request_data.dart';
import 'package:fieldpro_genworks_healthcare/network/db/ticket_for_the_day.dart';
import 'package:fieldpro_genworks_healthcare/network/db/ticket_for_the_day_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/training_list_data.dart';
import 'package:fieldpro_genworks_healthcare/network/db/training_list_data_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/travel_update_request_data.dart';
import 'package:fieldpro_genworks_healthcare/network/db/travel_update_request_data_dao.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;


import 'amc_ticket_details.dart';
import 'amc_ticket_details_dao.dart';
import 'assessment_question_data.dart';
import 'assessment_question_data_dao.dart';
import 'assessment_quiz_data.dart';
import 'assessment_quiz_data_dao.dart';
import 'consumed_spare_request_data.dart';
import 'consumed_spare_request_data_dao.dart';
import 'direction_details.dart';
import 'direction_details_dao.dart';
import 'installation_report_data.dart';
import 'installation_report_data_dao.dart';
import 'new_amc_creation_data.dart';
import 'new_amc_creation_data_dao.dart';
import 'new_ticket.dart';
import 'new_ticket_dao.dart';
import 'ongoing_ticket.dart';
import 'ongoing_ticket_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [
  NewTicketTable,
  TicketForTheDayTable,
  AmcDetailsTicketTable,
  OngoingTicketTable,
  ConsumedSpareRequestDataTable,
  SpareRequestDataTable,
  InstallationReportDataTable,
  SearchAMCContractDataTable,
  TravelUpdateRequestData,
  SerialNoDataTable,
  NewAMCCreationDataTable,
  AssessmentQuestionDataTable,
  AssessmentQuizDataTable,
  TrainingListDataTable,
  SmartScheduleDataTable,
  DirectionDetailsTable,
  SelectedOnHandSpareDataTable
])
abstract class AppDatabase extends FloorDatabase {
  NewTicketDao get newTicketDao;

  TicketForTheDayDao get ticketForTheDayDao;

  AmcTicketDetailsDao get amcTicketDetailsDao;

  OngoingTicketDao get ongoingTicketDao;

  ConsumedSpareRequestDataDao get consumedSpareRequestDataDao;

  SpareRequestDataDao get spareRequestDataDao;

  InstallationReportDataDao get installationReportDataDao;

  SearchAMCContractDataDao get searchAMCContractDataDao;

  TravelUpdateRequestDataDao get travelUpdateRequestDataDao;

  SerialNoDataDao get serialNoDataDao;

  NewAMCCreationDataDao get newAMCCreationDataDao;

  AssessmentQuestionDataDao get assessmentQuestionDataDao;

  AssessmentQuizDataDao get assessmentQuizDataDao;

  TrainingListDataDao get trainingListDataDao;

  SmartScheduleDataDao get smartScheduleDataDao;

  DirectionDetailsDao get directionDetailsDao;

  SelectedOnHandSpareDao get selectedOnHandSpareDao;
}
