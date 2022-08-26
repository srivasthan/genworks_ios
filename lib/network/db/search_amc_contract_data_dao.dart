import 'package:fieldpro_genworks_healthcare/network/db/search_amc_contract_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class SearchAMCContractDataDao {
  @Query('SELECT * FROM SearchAMCContractDataTable')
  Future<List<SearchAMCContractDataTable>> findAllSearchAMCContractData();

  @insert
  Future<void> insertSearchAMCContractData(
      SearchAMCContractDataTable installationReportDataTable);

  @Query('SELECT * FROM SearchAMCContractDataTable WHERE id = :id')
  Future<List<SearchAMCContractDataTable>> findSearchAMCContractData(int id);

  @Query('DELETE FROM SearchAMCContractDataTable')
  Future<void> deleteSearchAMCContractDataTable();

  @delete
  Future<void> deleteSearchAMCContractData(
      SearchAMCContractDataTable installationReportDataTable);
}
