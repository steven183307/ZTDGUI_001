@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'AM_TYPE'

@ObjectModel : { resultSet.sizeCategory: #XS }
define view entity ZTDGUIC_MODULE_VH 
as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZTDGUIDO_MODULE')

{
      @UI.hidden: true
  key domain_name,

      @UI.hidden: true
  key value_position,

      @UI.hidden: true  
      @Semantics.language: true
  key language,
  

      value_low,
      
      @EndUserText.label: '狀態描述'    
      @Semantics.text: true
      text
}
