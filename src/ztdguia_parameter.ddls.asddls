@EndUserText.label: 'gui parameter'
@Metadata.allowExtensions: true
define abstract entity ztdguia_parameter
{
  @UI.defaultValue: '1000'
  bukrs   : abap.char(4);

  @UI.defaultValue: '2023'
  gjahr   : abap.numc(4);

  @UI.defaultValue: 'X'
  bkpf    : abap_boolean;
  
  budat   : abap.dats;
  budat2  : abap.dats;

  @UI.defaultValue: '1180000343'    
  belnr   : abap.char(10);

  @UI.defaultValue: '1180000351'    
  belnrto : abap.char(10);
  
  vbeln   : abap.char(10);
  usnam   : abp_creation_user;
  belnr2  : abap.char(10);

  zinvt   : abap_boolean;
  bldat   : abap.dats;
  xblnr   : abap.char(16);
  belnr3  : abap.char(10);

  @UI.defaultValue: 'X'
  skip    : abap_boolean;
}
