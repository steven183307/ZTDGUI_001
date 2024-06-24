@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company code value help'
define view entity ZTDGUIC_BUKRS_VH 

as select from ztdguit_t001 
{
    @EndUserText.label: '公司代碼'
    @UI.lineItem: [{ position: 10, label: '公司代碼' }]
    @Search.defaultSearchElement: true
    key bukrs as Bukrs,
    @EndUserText.label: '公司名稱'
    @UI.lineItem: [{ position: 20, label: '公司名稱' }]
    butxt as Butxt

} 
