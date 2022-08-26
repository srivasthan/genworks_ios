import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

import 'Response/add_amc_response.dart';
import 'Response/add_transfer_response.dart';
import 'Response/amc_product_response.dart';
import 'Response/amc_response.dart';
import 'Response/amc_sub_product_response.dart';
import 'Response/assessment_response.dart';
import 'Response/call_category_response.dart';
import 'Response/change_password.dart';
import 'Response/city_repsonse.dart';
import 'Response/country.dart';
import 'Response/dashboard_response.dart';
import 'Response/discount_response.dart';
import 'Response/drop_location.dart';
import 'Response/forgot_password.dart';
import 'Response/get_distance.dart';
import 'Response/impreset_response.dart';
import 'Response/installation_complete_response.dart';
import 'Response/kb_subproduct_response.dart';
import 'Response/location_response.dart';
import 'Response/login_response.dart';
import 'Response/new_ticket_response.dart';
import 'Response/on_hand_primay_response.dart';
import 'Response/on_hand_spare.dart';
import 'Response/ongoing_ticket.dart';
import 'Response/pending_frm.dart';
import 'Response/product_response.dart';
import 'Response/profile_response.dart';
import 'Response/refer_solution_response.dart';
import 'Response/requested_spare_list.dart';
import 'Response/select_technician_response.dart';
import 'Response/spare_cart_response.dart';
import 'Response/spare_receive_request.dart';
import 'Response/spare_status.dart';
import 'Response/spare_transfer_list.dart';
import 'Response/state_response.dart';
import 'Response/submitted_claim.dart';
import 'Response/suggested_technician_response.dart';
import 'Response/technician_punchin_response.dart';
import 'Response/ticket_for_day.dart';
import 'Response/ticket_schedule.dart';
import 'Response/token_response.dart';
import 'Response/tracking.dart';
import 'Response/training_reference_response.dart';
import 'Response/training_response.dart';
import 'Response/transfer.dart';
import 'Response/travel_update_response.dart';
import 'Response/work_type.dart';

part 'api_services.g.dart';

//flutter pub run build_runner build
@RestApi(baseUrl: "https://genworks.kaspontech.com/djadmin_qa/")
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) {
    dio.options = BaseOptions(
        receiveTimeout: 30000,
        connectTimeout: 30000,
        headers: {'Content-Type': 'application/json'});

    return _ApiService(dio, baseUrl: baseUrl);
  }

  @POST("technician_login/")
  Future<LoginResponse> technicianLogin(@Body() Map<String, dynamic> body);

  @POST("technician_forget_password")
  Future<ForgotPasswordResponse> forgotPassword(
      @Body() Map<String, dynamic> body);

  @POST("change_password/")
  Future<ChangePasswordResponse> changePassword(
      String token, @Body() Map<String, dynamic> body);

  @POST("technician_logout/")
  Future<ForgotPasswordResponse> logout(@Body() Map<String, dynamic> body);

  @GET("technician_profile")
  Future<ProfileResponse> getProfileDetails(
      String token, String technicianCode);

  @POST("edit_technician")
  Future<ChangePasswordResponse> uploadImage(
      String token, @Body() Map<String, dynamic> body);

  @GET("get_token")
  Future<TokenResponse> getToken(String technicianCode);

  @POST("technician_punch")
  Future<TechnicianPunchInResponse> technicianPunchIn(
      token, @Body() Map<String, dynamic> body);

  @PUT("technician_punch")
  Future<TechnicianPunchInResponse> technicianPunchOut(
      token, @Body() Map<String, dynamic> body);

  @GET("technician_new_ticket")
  Future<NewTicketResponse> newTicket(String token, String technicianCode);

  @GET("technician_ongoing_ticket")
  Future<OngoingTicketResponse> onGoingTicket(
      String token, String technicianCode);

  @GET("technician_ticket_for_day")
  Future<TicketForTheDayResponse> ticketForTheDay(
      String token, String technicianCode);

  @POST("technician_ticket_accept")
  Future<ChangePasswordResponse> acceptTicket(
      String? token, @Body() Map<String, dynamic> body);

  @POST("technician_ticket_reject")
  Future<ChangePasswordResponse> rejectTicket(
      String? token, @Body() Map<String, dynamic> body);

  @GET("get_product_details/")
  Future<ProductResponse> getProducts();

  @GET("spare_status")
  Future<SpareStatusResponse> spareStatusGetApi(
      String token, String technicianCode);

  @GET("pending_frm")
  Future<PendingFrmResponse> pendingFrmGetApi(
      String token, String technicianCode);

  @GET("on_hand_spare")
  Future<OnHandSpareResponse> onHandSpareGetApi(
      String token, String technicianCode);

  @GET("requested_spare_list")
  Future<RequestedSpareListResponse> requestedSpareList(
      String token, String technicianCode);

  @GET("spare_transfer_list")
  Future<SpareTransferResponse> spareTransferListGetApi(
      String token, String technicianCode);

  @GET("spare_recive_list")
  Future<SpareReceiveResponse> spareReceiveListGetApi(
      String token, String technicianCode);

  @POST("accept_transfer_spare")
  Future<TransferResponse> acceptTransferSpare(
      String? token, @Body() Map<String, dynamic> body);

  @POST("recive_transfer_spare")
  Future<TransferResponse> receiveTransferSpare(
      String? token, @Body() Map<String, dynamic> body);

  @POST("technician_skill/")
  Future<SelectTechnicianResponse> selectTechnicianList(
      @Body() Map<String, dynamic> body);

  @POST("onhand_spare/")
  Future<OnHandPrimaryResponse> getConsumedSpareList(
      String? token, @Body() Map<String, dynamic> body);

  @POST("add_spare_transfer")
  Future<AddTransferResponse> postAddSpareTransfer(
      String? token, @Body() Map<String, dynamic> body);

  @GET("get_spare")
  Future<SpareCartResponse> getSpareCart(String token, String technicianCode,
      String wareHouseId, String ticketId, String spare, String frmSpare);

  @POST("personal_spare_request")
  Future<AddTransferResponse> postPersonalSpareRequest(
      String? token, @Body() Map<String, dynamic> body);

  @POST("update_frm")
  Future<AddTransferResponse> getupdateFieldReturnMatrial(
      String? token, @Body() Map<String, dynamic> body);

  @POST("start_travel")
  Future<TransferResponse> fieldProstarttravel(
      String? token, @Body() Map<String, dynamic> body);

  @GET("get_distance")
  Future<GetDistanceResponse> getDistance(
      String currentLatitude,
      String currentLongitude,
      String destinationLatitude,
      String destinationLongitude);

  @POST("end_travel")
  Future<AddTransferResponse> endTravel(
      String? token, @Body() Map<String, dynamic> body);

  @POST("bill")
  Future<AddTransferResponse> fieldProTransportBill(
      String? token, @Body() Map<String, dynamic> body);

  @POST("ticket_start")
  Future<AddTransferResponse> startTicket(
      String? token, @Body() Map<String, dynamic> body);

  @GET("get_service_category")
  Future<InstallationCompleteResponse> serviceCategory(
      String token, String technicianCode, String serviceId);

  @POST("create_service_activite")
  Future<AddTransferResponse> serviceActivity(
      String? token, @Body() Map<String, dynamic> body);

  @POST("imprest_spare_track")
  Future<ImpresetResponse> consumedSpareRequest(
      String? token, @Body() Map<String, dynamic> body);

  @POST("price_discount_range/")
  Future<ForgotPasswordResponse> discountDetail(
      String? token, @Body() Map<String, dynamic> body);

  @POST("submit_complete_from")
  Future<AddTransferResponse> submitComplete(
      String? token, @Body() FormData body);

  @POST("verify_otp")
  Future<AddTransferResponse> verifyOtp(
      String? token, @Body() Map<String, dynamic> body);

  @POST("return_pending_frm")
  Future<AddTransferResponse> pendingFrm(
      String? token, @Body() Map<String, dynamic> body);

  @GET("get_warehouse/")
  Future<DropLocationResponse> getDropLocationApi();

  @PUT("price_discount_range/")
  Future<DiscountResponse> discountConsumedSpareRequest(
      String? token, @Body() Map<String, dynamic> body);

  @POST("request_spare_form")
  Future<AddTransferResponse> submitFromRequestSpare(
      String? token, @Body() FormData body);

  @POST("work_in_progress_form")
  Future<AddTransferResponse> submitFromWorkInProgressFrom(
      String? token, @Body() FormData body);

  @POST("suggested_technicians/")
  Future<SuggestedTechnicianResponse> getSuggestedTechnicians(
      @Body() Map<String, dynamic> body);

  @POST("submit_escalate")
  Future<AddTransferResponse> submitEscalateTicket(
      String? token, @Body() FormData body);

  @POST("ticket_schedule")
  Future<TicketScheduleResponse> ticketSchedule(
      String? token, @Body() Map<String, dynamic> body);

  @POST("technician_dashboard/")
  Future<DashBoardResponse> technicianDashboard(
      @Body() Map<String, dynamic> body);

  @GET("tech_subproduct_details/")
  Future<KBSubProductResponse> getKnowledgeBaseSubProductList(int? productId);

  @POST("knowledge_base_solution")
  Future<AddTransferResponse> enterSolution(
      String? token, @Body() FormData body);

  @POST("refer_knowledge_base_solution")
  Future<ReferSolutionResponse> referKnowledgeBaseSolution(
      String? token, @Body() Map<String, dynamic> body);

  @GET("training")
  Future<TrainingResponse> training(String? token, String? technicianCode);

  @POST("amc_search")
  Future<AMCResponse> amcSearch(
      String? token, @Body() Map<String, dynamic> body);

  @GET("submited_claims")
  Future<SubmittedClaimResponse> submittedClaim(
      String? token, String? technicianCode);

  @POST("reimbursment_request")
  Future<AddTransferResponse> submitNewClaim(
      String? token, @Body() Map<String, dynamic> body);

  @POST("travel_list/")
  Future<TravelUpdateResponse> getTravelUpdate(
      String? token, @Body() Map<String, dynamic> body);

  @POST("reimbursement_bill/")
  Future<AddTransferResponse> updateTravel(
      String? token, @Body() Map<String, dynamic> body);

  @GET("get_amc_details/")
  Future<AddAMCResponse> getAMC();

  @GET("get_servicegroup/")
  Future<WorkTypeResponse> getWorkType();

  @GET("get_country/")
  Future<CountryResponse> getCountry();

  @GET("get_product_details/")
  Future<AMCProductResponse> getAMCProduct();

  @GET("get_call_category/")
  Future<CallCategoryResponse> getCallCategory();

  @GET("get_state/")
  Future<StateResponse> getState(int? countryId);

  @GET("get_city/")
  Future<CityResponse> getCity(int? stateId);

  @GET("get_location_details/")
  Future<LocationResponse> getLocation(int? stateId);

  @GET("tech_subproduct_details/")
  Future<AMCSubProductResponse> getAMCSubProduct(int? productId);

  @POST("validate_cus_serial_no/")
  Future<AddTransferResponse> validateSerialNo(
      @Body() Map<String, dynamic> body);

  @POST("product_amc")
  Future<AddTransferResponse> addNewProductAmc(
      String? token, @Body() Map<String, dynamic> body);

  @POST("technician_renew_amc")
  Future<AddTransferResponse> technicianRenewAmc(
      String? token, @Body() Map<String, dynamic> body);

  @POST("amc")
  Future<AddTransferResponse> createNewAmcResult(
      String? token, @Body() Map<String, dynamic> body);

  @POST("submit_amc")
  Future<AddTransferResponse> submitAMCTicket(
      String? token, @Body() Map<String, dynamic> body);

  @GET("certificate")
  Future<AssessmentResponse> assessmentList(
      String? token, String? technicianCode);

  @POST("training_reference_details/")
  Future<TrainingReferenceResponse> trainingReferenceDetails(
      String? token, @Body() Map<String, dynamic> body);

  @POST("submit_quiz")
  Future<AddTransferResponse> submitQuizDataAssessment(
      String? token, @Body() Map<String, dynamic> body);

  @POST("add_technician_tracker/?")
  Future<TrackingResponse> technicianTracking({String? queryString});
}
