@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZFORM_CODE value help'

@ObjectModel : { resultSet.sizeCategory: #XS }
define view entity ZTDGUIC_ZFORM_CODE_VH 
as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZTDGUIDO_ZFORM_CODE')

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
