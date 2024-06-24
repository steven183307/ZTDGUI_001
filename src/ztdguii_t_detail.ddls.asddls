@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T_detail interface view'
@UI.presentationVariant: [{maxItems: 15 }]
define view entity ZTDGUII_T_detail
  as select from ztdguit_t_detail as detail
  association to parent ZTDGUII_T_head as _HEAD on $projection.HeadID = _HEAD.HeadID
  association to ztdguit_t001          as _t001 on $projection.Bukrs = _t001.bukrs
{
  key  detailid           as detailid,
  key  headid             as HeadID,
       case
       when statusmsg  = '已刪除' then 1
       when statusmsg  = '不完整' then 2
       else 3
       end                as criticality1,
       @EndUserText.label: '項次'
       itemno             as itemno,
       @EndUserText.label: '公司代碼'
       bukrs              as Bukrs,
       @EndUserText.label: '會計文件號碼'
       belnr              as Belnr,
       @EndUserText.label: '會計年度'
       gjahr              as Gjahr,
       zaehl              as Zaehl,
       @EndUserText.label: '憑證號碼'
       xblnr              as Xblnr,
       xjahr              as Xjahr,
       @EndUserText.label: '憑證日期'
       bldat              as Bldat,
       @EndUserText.label: '申報日期'
       vatdate            as Vatdate,
       @EndUserText.label: '銷售額'
       @Semantics.amount.currencyCode : 'waers'
       hwbas              as Hwbas,
       @EndUserText.label: '稅額'
       @Semantics.amount.currencyCode : 'waers'
       hwste              as Hwste,
       of_flag            as OfFlag,
       @Semantics.amount.currencyCode : 'waers'
       hwbas_of           as HwbasOf,
       @Semantics.amount.currencyCode : 'waers'
       hwste_of           as HwsteOf,
       @EndUserText.label: '統一編號'
       stceg              as Stceg,
       @EndUserText.label: '格式'
       zform_code         as Zform_Code,
       @EndUserText.label: '格式說明'
       zformtext          as ZformText,
       @EndUserText.label: '交易類型'
       am_type            as Am_Type,
       @EndUserText.label: '交易類型說明'
       amtype_text        as amtype_text,
       @EndUserText.label: '課稅別'
       tax_type           as Tax_Type,
       @EndUserText.label: '課稅別說明'
       taxtype_text       as taxtype_text,
       @EndUserText.label: '出口方式'
       zexport            as Zexport,
       @EndUserText.label: '出口方式'
       zexport_text       as zexport_text,
       @EndUserText.label: '挪用下一次字軌'
       div_flag           as DivFlag,
       @EndUserText.label: '三/二聯'
       copies             as Copies,
       @EndUserText.label: '三/二聯說明'
       copies_text        as copies_text,
       @EndUserText.label: '經海關註記'
       cust_flag          as CustFlag,
       @EndUserText.label: '買受人名稱'
       custname           as Custname,
       @EndUserText.label: '貸貨名稱'
       arktx              as Arktx,
       @EndUserText.label: '貨物數量'
       menge              as Menge,
       @EndUserText.label: '非經 名稱'
       non_customs_name   as NonCustomsName,
       @EndUserText.label: '非經 號碼'
       non_customs_no     as NonCustomsNo,
       @EndUserText.label: '報關類別'
       customs_type       as CustomsType,
       @EndUserText.label: '報關號碼'
       customs_no         as CustomsNo,
       @EndUserText.label: '報關日'
       customs_date       as CustomsDate,
       awtyp              as Awtyp,
       awkey              as Awkey,
       vbeln              as Vbeln,
       fkart              as Fkart,
       fkdat              as Fkdat,
       aubel              as Aubel,
       loekz              as Loekz,
       @EndUserText.label: '刪除碼'
       canl               as Canl,
       @EndUserText.label: '稅區代碼'
       vatcode            as Vatcode,
       @EndUserText.label: '忽略檢查'
       notcheck           as Notcheck,
       pupflag            as Pupflag,
       autoflag           as Autoflag,
       ernam              as Ernam,
       erdat              as Erdat,
       erzet              as Erzet,
       @EndUserText.label: '配號(Test)'
       aenam              as Aenam,
       aedat              as Aedat,
       desc_coll          as DescColl,
       history            as History,
       kunnr              as Kunnr,
       ptr_fg             as PtrFg,
       remark             as Remark,
       crserialno         as Crserialno,
       mwskz              as Mwskz,
       seq                as Seq,
       cr_desc            as crdesc,
       cr_qty             as CrQty,
       cr_price           as CrPrice,
       reuse_fg           as ReuseFg,
       copy_fg            as CopyFg,
       notvat             as Notvat,
       xblnr_f            as XblnrF,
       lgort              as Lgort,
       cash_reg_snum      as CashRegSnum,
       posflag            as Posflag,
       xblnr_end          as XblnrEnd,
       cr_no              as CrNo,
       vatdate_cr         as VatdateCr,
       coll_canl_date     as CollCanlDate,
       coll_canl_time     as CollCanlTime,
       coll_fg            as CollFg,
       mblnr              as Mblnr,
       seq_presales       as SeqPresales,
       matnr              as Matnr,
       ptr                as Ptr,
       vrkme              as Vrkme,
       posnr              as Posnr,
       sto_fg             as StoFg,
       budat              as Budat,
       manl_fg            as ManlFg,
       x2b2_fg            as X2b2Fg,
       b2_fg              as B2Fg,
       b2_doc             as B2Doc,
       x2_fg              as X2Fg,
       x2_doc             as X2Doc,
       vbeln_vl           as VbelnVl,
       mjahr              as Mjahr,
       vfcod              as Vfcod,
       carriertype        as Carriertype,
       carrierid1         as Carrierid1,
       carrierid2         as Carrierid2,
       donatemark         as Donatemark,
       donatetarget       as Donatetarget,
       @EndUserText.label: '作廢日'
       canl_date          as CanlDate,
       @EndUserText.label: '作廢時間'
       canl_time          as CanlTime,
       @EndUserText.label: '作廢者'
       @Semantics.user.lastChangedBy: true
       canluser           as CanlUser,
       canl_flag          as CanlFlag,
       pre_so             as PreSo,
       edigui             as Edigui,
       void               as VoID,
       voiddate           as Voiddate,
       voidtime           as Voidtime,
       in_outbound        as InOutbound,
       eguitype           as Eguitype,
       ecr_flag           as EcrFlag,
       @EndUserText.label: '配號狀態'       
       nummsg             as nummsg,
       msatz              as Msatz,
       @EndUserText.label: 'For Hide Field'
       hidefield          as Hidefield,
       stblg              as Stblg,
       stjah              as Stjah,
       @EndUserText.label: '錯誤訊息'
       errormsg           as errormsg,
       @EndUserText.label: '說明(折)'
       discountmsg        as discountmsg,
       @EndUserText.label: '數量(折)'
       discountq          as discountq,
       @EndUserText.label: '單價(折)'
       discountu          as discountu,
       waers              as waers,
       @EndUserText.label: '狀態'
       statusmsg          as statusmsg,
       @Semantics.user.createdBy: true
       createdby          as CreatedBy,
       @Semantics.systemDateTime.createdAt: true
       createdat          as CreatedAt,
       lastchangedby      as Lastchangedby,
       @Semantics.systemDateTime.lastChangedAt: true
       lastchangedat      as Lastchangedat,
       @Semantics.systemDateTime.localInstanceLastChangedAt: true
       locallastchangedat as Locallastchangedat,
       _HEAD.Hidefield    as HEADHIDE,
       _HEAD,
       _t001
}
