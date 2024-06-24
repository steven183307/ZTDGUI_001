CLASS lhc__detail DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR _detail RESULT result.

    METHODS copyInstance FOR MODIFY
      IMPORTING keys FOR ACTION _detail~copyInstance.

    METHODS checkXblnr FOR VALIDATE ON SAVE
      IMPORTING keys FOR _detail~checkXblnr.

    METHODS checkSTCEG FOR VALIDATE ON SAVE
      IMPORTING keys FOR _detail~checkSTCEG.

    METHODS calcTotal_u_bas FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _detail~calcTotal_u_bas .

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR _detail RESULT result.

    METHODS checkwaers FOR VALIDATE ON SAVE
      IMPORTING keys FOR _detail~checkwaers.

    METHODS fillitemno FOR DETERMINE ON SAVE
      IMPORTING keys FOR _detail~fillitemno.

    METHODS deleteitem FOR MODIFY
      IMPORTING keys   FOR ACTION _detail~deleteitem
      RESULT    result.

    METHODS updatestatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR _detail~updatestatus.

    METHODS assignnumber FOR MODIFY
      IMPORTING keys FOR ACTION _detail~assignnumber RESULT result.

    METHODS canceldelete FOR MODIFY
      IMPORTING keys FOR ACTION _detail~canceldelete RESULT result.

    METHODS hidecontrol FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _detail~hidecontrol.

    METHODS changearktx FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _detail~changearktx.

ENDCLASS.

CLASS lhc__detail IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD copyInstance.

    DATA: lt_detail TYPE TABLE FOR CREATE ZTDGUII_T_head\_detail.

    DATA(n1) = 0.
    DATA: lt_update_h TYPE TABLE FOR UPDATE ztdguii_t_head,
          ls_update_h TYPE STRUCTURE FOR UPDATE ztdguii_t_head.

    DATA: lt_update_d TYPE TABLE FOR CREATE ztdguii_t_head\_detail,
          ls_update_d TYPE STRUCTURE FOR CREATE ztdguii_t_head\_detail.

    READ ENTITIES OF ztdguii_t_head IN LOCAL MODE
    ENTITY _detail
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(details)
    FAILED failed.

    READ TABLE details ASSIGNING FIELD-SYMBOL(<lfs_details0>) INDEX 1.
    APPEND VALUE #(
                    HeadID =  <lfs_details0>-HeadID
                    %is_draft = keys[ KEY entity %key = <lfs_details0>-%key ]-%param-%is_draft
*                    %is_draft = 01
                    %target = CORRESPONDING #( details EXCEPT detailid )
     ) TO lt_update_d.

    READ TABLE lt_update_d ASSIGNING FIELD-SYMBOL(<lfs_details1>) INDEX 1.
    READ TABLE <lfs_details1>-%target ASSIGNING FIELD-SYMBOL(<lfs_details2>) INDEX 1.
    n1 = n1 + 1.
    <lfs_details2>-%cid = n1.

    "Create BO Instance by Copy
    MODIFY ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
    ENTITY _head
    CREATE BY \_detail
    FIELDS (
*             Zform_Code ZformText
*             Hwbas Hwste HwbasOf HwsteOf
*             Aenam
             criticality1 HeadID   Bukrs       Belnr  Gjahr Zaehl Xblnr
             Xjahr        Bldat    Vatdate     OfFlag
             Stceg        Am_Type  amtype_text Tax_Type taxtype_text
             Zexport      zexport_text DivFlag Copies
             copies_text  CustFlag Custname Arktx Menge
             NonCustomsName NonCustomsNo CustomsType
             CustomsNo CustomsDate Awtyp Awkey Vbeln Fkart Fkdat Aubel
             Loekz Canl Vatcode Notcheck Pupflag Autoflag
             Ernam Erdat Erzet Aedat DescColl History
             Kunnr PtrFg Remark Crserialno Mwskz Seq CrDesc CrQty CrPrice
             ReuseFg CopyFg Notvat XblnrF Lgort CashRegSnum
             Posflag XblnrEnd CrNo VatdateCr CollCanlDate CollCanlTime CollFg Mblnr
             SeqPresales Matnr Ptr Vrkme Posnr StoFg Budat
             ManlFg X2b2Fg B2Fg B2Doc X2Fg X2Doc VbelnVl Mjahr Vfcod
             Carriertype Carrierid1 Carrierid2
             Donatemark Donatetarget CanlDate CanlTime CanlFlag PreSo Edigui VoID
             Voiddate Voidtime InOutbound
             Eguitype EcrFlag Msatz Stblg Stjah waers
             CanlUser errormsg discountmsg discountq discountu
     )
    WITH lt_update_d
    MAPPED DATA(mapped_1)
    REPORTED DATA(reported_1)
    FAILED DATA(failed_1).

    IF failed_1 IS NOT INITIAL.
      LOOP AT reported_1-_head ASSIGNING FIELD-SYMBOL(<fs_header_mapped>).
        DATA(lv_error_msg1) = <fs_header_mapped>-%msg->if_message~get_text( ).
      ENDLOOP.
      LOOP AT reported_1-_detail ASSIGNING FIELD-SYMBOL(<fs_detail_mapped>).
        DATA(lv_error_msg2) = <fs_detail_mapped>-%msg->if_message~get_text( ).
      ENDLOOP.
    ENDIF.

    mapped-_detail = mapped_1-_detail.

  ENDMETHOD.

  METHOD checkXblnr.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
    ENTITY _detail
    ALL FIELDS  WITH CORRESPONDING #( keys )
    RESULT DATA(checkXblnrs).

    LOOP AT checkXblnrs INTO DATA(checkXblnr).

      APPEND VALUE #(  %tky                 = checkXblnr-%tky
                       %state_area          = 'VALIDATE_XBLNR1'
                     ) TO reported-_detail.

      APPEND VALUE #(  %tky                 = checkXblnr-%tky
                       %state_area          = 'VALIDATE_XBLNR_M'
                     ) TO reported-_detail.

      IF checkXblnr-Xblnr IS INITIAL.
*************************************************************************
*        DO 10000 TIMES.
*************************************************************************
        APPEND VALUE #( %tky = checkxblnr-%tky ) TO failed-_detail.

        APPEND VALUE #(  %tky                 = checkXblnr-%tky
                         %state_area          = 'VALIDATE_XBLNR_M'
                         %path = VALUE #(
                                          _head-%is_draft   = checkXblnr-%is_draft
                                          _head-%key-HeadID = checkXblnr-HeadID
                                         )
                         %msg = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = '請輸入憑證號碼' )
                         %element-Xblnr  = if_abap_behv=>mk-on
                       ) TO reported-_detail.
*************************************************************************
*        ENDDO.
*************************************************************************
      ELSE.

        DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
*        iv_ignore_case = abap_true
        ).

        DATA(lv_case_insensitive_matches) = xco_cp=>string( checkXblnr-xblnr )->matches(
          iv_regular_expression = '^([A-Z]{1}[A-Z]{1})[0-9]{8}$'
          io_engine             = lo_posix_engine
        ).

        IF lv_case_insensitive_matches IS INITIAL.
          APPEND VALUE #( %tky = checkxblnr-%tky ) TO failed-_detail.

          APPEND VALUE #(  %tky                 = checkXblnr-%tky
                         %state_area          = 'VALIDATE_XBLNR1'
                         %path = VALUE #(
                                          _head-%is_draft   = checkXblnr-%is_draft
                                          _head-%key-HeadID = checkXblnr-HeadID
                                         )
                           %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = '憑證號碼格式錯誤' )
                         %element-Xblnr  = if_abap_behv=>mk-on
                         ) TO reported-_detail.
        ELSE.

          APPEND VALUE #(  %tky                 = checkXblnr-%tky
                           %state_area          = 'VALIDATE_XBLNR1'
                         ) TO reported-_detail.

          APPEND VALUE #(  %tky                 = checkXblnr-%tky
                           %state_area          = 'VALIDATE_XBLNR_M'
                         ) TO reported-_detail.

        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD checkSTCEG.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
        ENTITY _detail
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(checkSTCEGs).

    LOOP AT checkSTCEGs INTO DATA(checkSTCEG).

*      APPEND VALUE #(  %tky                 = checkSTCEG-%tky
*                       %state_area          = 'VALIDATE_STCEG1'
*                     ) TO reported-_detail.

      CHECK checkSTCEG-Stceg IS NOT INITIAL.

      DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
*        iv_ignore_case = abap_true
      ).

      DATA(lv_case_insensitive_matches) = xco_cp=>string( checkSTCEG-stceg )->matches(
        iv_regular_expression = '^[0-9]{8}$'
        io_engine             = lo_posix_engine
      ).

      IF lv_case_insensitive_matches IS INITIAL.

        APPEND VALUE #(  %tky                 = checkSTCEG-%tky
                         %state_area          = 'VALIDATE_STCEG1'
                       ) TO reported-_detail.

*        APPEND VALUE #( %tky = checkSTCEG-%tky ) TO failed-_detail.

        APPEND VALUE #(  %tky                 = checkSTCEG-%tky
                         %state_area          = 'VALIDATE_STCEG1'
                         %path = VALUE #(
                                          _head-%is_draft   = checkSTCEG-%is_draft
                                          _head-%key-HeadID = checkSTCEG-HeadID
                                         )
                         %msg = new_message_with_text(
                                severity = if_abap_behv_message=>severity-warning
                                text     = '統一編號格式錯誤' )
                         %element-Stceg  = if_abap_behv=>mk-on
                       ) TO reported-_detail.
      ELSE.

        APPEND VALUE #(  %tky                 = checkSTCEG-%tky
                         %state_area          = 'VALIDATE_STCEG1'
                       ) TO reported-_detail.

      ENDIF.

    ENDLOOP.

*    MODIFY ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
*    ENTITY _detail
*    UPDATE FIELDS ( statusmsg )
*      WITH VALUE #( ( %key-detailid  = checkSTCEG-detailid
*                      statusmsg = '正常' ) )
*    MAPPED DATA(mapped_copy)
*    REPORTED DATA(reported_copy)
*    FAILED DATA(failed_copy).

  ENDMETHOD.

  METHOD calcTotal_u_bas.

    DATA:
      l_currecycode TYPE ZTDGUII_T_head-waers,
      l_S_BAS       TYPE ZTDGUII_T_head-Hwbas,
      l_S_STE       TYPE ZTDGUII_T_head-Hwste,
      l_U_BAS       TYPE ZTDGUII_T_detail-Hwbas,
      l_U_STE       TYPE ZTDGUII_T_detail-Hwste,
      l_C_BAS       TYPE ZTDGUII_T_detail-Hwbas,
      l_C_STE       TYPE ZTDGUII_T_detail-Hwste.
    DATA l_headid TYPE ZTDGUITD_detail-headid.
    DATA: ls_head TYPE STRUCTURE FOR UPDATE ZTDGUII_T_head,
          lt_head TYPE TABLE FOR UPDATE  ZTDGUII_T_head.
    DATA ls_draft TYPE abp_behv_flag.

**********************************************************************
    DATA: lt_update_h TYPE TABLE FOR UPDATE ztdguii_t_head,
          ls_update_h TYPE STRUCTURE FOR UPDATE ztdguii_t_head.
    DATA(l_flag) = 0.
    DATA n1 TYPE i.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
    ENTITY _detail
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_total_D100).

    DATA l_headid_for_get_data TYPE ztdguit_t_head-headid.

    SORT lt_total_D100 BY HeadID ASCENDING.

    l_headid = lt_total_D100[ 1 ]-HeadID.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
      ENTITY _head
      ALL FIELDS
      WITH VALUE #( ( HeadID = l_headid  ) )
      RESULT DATA(lt_total_D88).

    LOOP AT lt_total_D88 ASSIGNING FIELD-SYMBOL(<fs_88>).
      <fs_88>-%is_draft = 01.
    ENDLOOP.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
    ENTITY _head BY \_detail
    ALL FIELDS
    WITH  CORRESPONDING #(  lt_total_D88  )
    RESULT DATA(lt_total_D99).

    ls_draft = 01.

    IF lt_total_D99 IS INITIAL.
      LOOP AT lt_total_D88 ASSIGNING FIELD-SYMBOL(<fs_99>).
        <fs_99>-%is_draft = 00.
      ENDLOOP.

      READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
      ENTITY _head BY \_detail
      ALL FIELDS
      WITH  CORRESPONDING #(  lt_total_D88  )
      RESULT lt_total_D99.
      ls_draft = 00.

    ENDIF.


    LOOP AT lt_total_D99 ASSIGNING  FIELD-SYMBOL(<fs_total_d99>) WHERE canl = ''.

      IF  <fs_total_d99>-statusmsg <> '已刪除'.
        l_flag = 1.
        n1 = n1 + 1.
        IF l_headid <> <fs_total_d99>-HeadID.   "不同Header
          CLEAR: l_u_bas, l_u_ste, l_c_bas, l_c_ste.

          CASE <fs_total_d99>-zform_code.
            WHEN 31 OR 32 OR 35 OR 36 OR 37.
              l_u_bas += <fs_total_d99>-hwbas.
              l_u_ste += <fs_total_d99>-hwste.
            WHEN 33 OR 34 OR 38.
              l_c_bas -= <fs_total_d99>-hwbas.
              l_c_ste -= <fs_total_d99>-hwste.
          ENDCASE.

          l_headid = <fs_total_d99>-HeadID.

          ls_update_h = VALUE #(  %is_draft = ls_draft
                                  %key-HeadID =  l_headid
                                  u_bas = l_u_bas
                                  u_ste = l_u_ste
                                  c_bas = l_c_bas
                                  c_ste = l_c_ste
                                  %control = VALUE #(
                                        u_bas = cl_abap_behv=>flag_changed
                                        u_ste = cl_abap_behv=>flag_changed
                                        c_bas = cl_abap_behv=>flag_changed
                                        c_ste = cl_abap_behv=>flag_changed
                                                     ) ) .
          APPEND ls_update_h TO lt_update_h.


        ELSE. "同一個Header
          CASE <fs_total_d99>-zform_code.
            WHEN 31 OR 32 OR 35 OR 36 OR 37.
              l_u_bas += <fs_total_d99>-hwbas.
              l_u_ste += <fs_total_d99>-hwste.
            WHEN 33 OR 34 OR 38.
              l_c_bas -= <fs_total_d99>-hwbas.
              l_c_ste -= <fs_total_d99>-hwste.
          ENDCASE.

          DELETE lt_update_h WHERE HeadID = <fs_total_d99>-HeadID.

          ls_update_h = VALUE #(  %is_draft = ls_draft "keys[ 1 ]-%is_draft
                                  %key-HeadID = l_headid
                                  u_bas = l_u_bas
                                  u_ste = l_u_ste
                                  c_bas = l_c_bas
                                  c_ste = l_c_ste
                                  %control = VALUE #(
                                        u_bas = cl_abap_behv=>flag_changed
                                        u_ste = cl_abap_behv=>flag_changed
                                        c_bas = cl_abap_behv=>flag_changed
                                        c_ste = cl_abap_behv=>flag_changed
                                                     ) ) .
          APPEND ls_update_h TO lt_update_h.


        ENDIF.

      ENDIF.

    ENDLOOP.

    "**Start of 更新憑證/折讓Total欄位資料*****
    IF l_flag = 0.

      MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
      ENTITY _head
      UPDATE FIELDS ( c_bas
                      c_ste
                      u_bas
                      u_ste )
        WITH VALUE #( ( %is_draft = ls_draft "keys[ 1 ]-%is_draft
                        %key-HeadID  = l_headid
                        c_bas = ''
                        c_ste = ''
                        u_bas = ''
                        u_ste = ''
                        ) )
      MAPPED DATA(mapped_ini)
      FAILED DATA(failed_ini)
      REPORTED DATA(reported_ini).

    ELSE.


      MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
        ENTITY _head
        UPDATE FROM lt_update_h
        MAPPED DATA(mapped2)
        FAILED DATA(failed2)
        REPORTED DATA(reported2).

*      READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
*        ENTITY _head
*        ALL FIELDS
*        WITH VALUE #( ( HeadID = l_headid  ) )
*        RESULT DATA(lt_total_Final).


    ENDIF.
    "**End of 更新憑證/折讓Total欄位資料*****

  ENDMETHOD.


  METHOD get_instance_features.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
      ENTITY _detail
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_detail).

    LOOP AT lt_detail INTO DATA(ls_detail).

      "**客製按鈕開關控制**==============================
      IF ls_detail-%is_draft EQ '00'.
        INSERT VALUE #(
          %tky = ls_detail-%tky
          %action-copyInstance = if_abap_behv=>fc-o-disabled
          %action-deleteItem   = if_abap_behv=>fc-o-disabled
          %action-assignNumber = if_abap_behv=>fc-o-disabled
          %action-cancelDelete = if_abap_behv=>fc-o-disabled
        ) INTO TABLE result.
      ELSE.
        INSERT VALUE #(
          %tky = ls_detail-%tky
          %delete              = COND #( WHEN ls_detail-statusmsg IS INITIAL
                                         THEN if_abap_behv=>fc-o-enabled
                                         ELSE if_abap_behv=>fc-o-disabled )
          %action-copyInstance = if_abap_behv=>fc-o-enabled
          %action-assignNumber = COND #( WHEN ls_detail-Aenam IS NOT INITIAL
                                           OR ls_detail-statusmsg = '已刪除'
                                         THEN if_abap_behv=>fc-o-disabled
                                         ELSE if_abap_behv=>fc-o-enabled )
          %action-deleteItem   = COND #( WHEN ls_detail-itemno IS INITIAL
                                           OR ls_detail-%is_draft = '00'
                                           OR ls_detail-statusmsg = '已刪除'
                                         THEN if_abap_behv=>fc-o-disabled
                                         ELSE if_abap_behv=>fc-o-enabled )
          %action-cancelDelete = COND #( WHEN ls_detail-statusmsg = '已刪除' "or ls_detail-statusmsg = ''
                                         THEN if_abap_behv=>fc-o-enabled
                                         ELSE if_abap_behv=>fc-o-disabled )
        ) INTO TABLE result.
      ENDIF.
      "**客製按鈕開關控制**==============================

      "**Entity為"已刪除"的狀態控制**==============================
      IF ls_detail-statusmsg = '已刪除' AND ls_detail-%is_draft EQ '01'.
        INSERT VALUE #(
          %tky = ls_detail-%tky
          %action-copyInstance  = if_abap_behv=>fc-o-disabled
          %action-deleteItem    = if_abap_behv=>fc-o-disabled
          %action-assignNumber  = if_abap_behv=>fc-o-disabled
          %delete               = if_abap_behv=>fc-o-disabled
          %field-Bldat          = if_abap_behv=>fc-f-read_only
          %field-Vatdate        = if_abap_behv=>fc-f-read_only
          %field-Xblnr          = if_abap_behv=>fc-f-read_only
          %field-Zform_Code     = if_abap_behv=>fc-f-read_only
          %field-Custname       = if_abap_behv=>fc-f-read_only
          %field-Copies         = if_abap_behv=>fc-f-read_only
          %field-Am_Type        = if_abap_behv=>fc-f-read_only
          %field-Hwste          = if_abap_behv=>fc-f-read_only
          %field-Hwbas          = if_abap_behv=>fc-f-read_only
          %field-Stceg          = if_abap_behv=>fc-f-read_only
          %field-errormsg       = if_abap_behv=>fc-f-read_only
          %field-Vatcode        = if_abap_behv=>fc-f-read_only
          %field-Notcheck       = if_abap_behv=>fc-f-read_only
          %field-Canl           = if_abap_behv=>fc-f-read_only
          %field-Zexport        = if_abap_behv=>fc-f-read_only
          %field-Tax_Type       = if_abap_behv=>fc-f-read_only
          %field-DivFlag        = if_abap_behv=>fc-f-read_only
          %field-NonCustomsNo   = if_abap_behv=>fc-f-read_only
          %field-NonCustomsName = if_abap_behv=>fc-f-read_only
          %field-Menge          = if_abap_behv=>fc-f-read_only
          %field-CustFlag       = if_abap_behv=>fc-f-read_only
          %field-Arktx          = if_abap_behv=>fc-f-read_only
          %field-discountu      = if_abap_behv=>fc-f-read_only
          %field-discountq      = if_abap_behv=>fc-f-read_only
          %field-discountmsg    = if_abap_behv=>fc-f-read_only
          %field-CanlUser       = if_abap_behv=>fc-f-read_only
          %field-CanlTime       = if_abap_behv=>fc-f-read_only
          %field-CanlDate       = if_abap_behv=>fc-f-read_only
          %field-CustomsDate    = if_abap_behv=>fc-f-read_only
          %field-CustomsType    = if_abap_behv=>fc-f-read_only
        ) INTO TABLE result.
      ENDIF.
      "**Entity為"已刪除"的狀態控制**==============================

      "**Entity為"特定會計文件號碼"的狀態控制**==============================
*      IF ls_detail-Custname = 'TD_ABAP股份有限公司'.
*        INSERT VALUE #(
*          %tky = ls_detail-%tky
*          %field-Custname       = if_abap_behv=>fc-f-read_only
*          %field-Stceg          = if_abap_behv=>fc-f-read_only
*        ) INTO TABLE result.
*      ENDIF.
      "**Entity為"特定會計文件號碼"的狀態控制**==============================

    ENDLOOP.

  ENDMETHOD.


  METHOD checkWaers.

*    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
*    ENTITY _detail
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_detail).
*
*    LOOP AT lt_detail INTO DATA(ls_detail).
*
*     IF ls_detail-waers IS INITIAL.
*
*        APPEND VALUE #( %tky = ls_detail-%tky ) TO failed-_detail.
*
*        APPEND VALUE #(  %tky                 = ls_detail-%tky
*                         %state_area          = 'VALIDATE_WAERS1'
*                         %path = VALUE #(
*                                          _head-%is_draft   = ls_detail-%is_draft
*                                          _head-%key-HeadID = ls_detail-HeadID
*                                         )
*                         %msg = new_message_with_text(
*                                severity = if_abap_behv_message=>severity-error
*                                text     = '幣別欄位不可以為空' )
*                         %element-waers  = if_abap_behv=>mk-on
*                       ) TO reported-_detail.
*      ELSE.
*
*        APPEND VALUE #(  %tky                 = ls_detail-%tky
*                         %state_area          = 'VALIDATE_WAERS1'
*                       ) TO reported-_detail.
*
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.


  METHOD fillItemNo.
    DATA l_headid TYPE ZTDGUITD_detail-headid.
    DATA l_itemn01 TYPE  ZTDGUITD_detail-itemno.
    DATA: ls_head TYPE STRUCTURE FOR UPDATE ZTDGUII_T_head,

          lt_head TYPE TABLE FOR UPDATE  ZTDGUII_T_head.

    READ ENTITIES OF  ZTDGUII_T_head IN LOCAL MODE
    ENTITY _detail
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_total_D).

    l_headid = lt_total_D[ 1 ]-HeadID.

    SELECT itemno
    FROM  ztdguit_t_detail
    WHERE headid  = @l_headid
    ORDER BY itemno DESCENDING
    INTO @DATA(l_itemno)
    UP TO 1 ROWS.
    ENDSELECT.

    LOOP AT lt_total_D INTO DATA(ls_detail).

      IF ls_detail-itemno IS INITIAL.
        l_itemno += 1.

        MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
        ENTITY _detail
        UPDATE FIELDS ( itemno )
        WITH VALUE #( ( detailid  = ls_detail-detailid
                        HeadID    = ls_detail-HeadID
                        itemno    = l_itemno
                     %control-itemno    = cl_abap_behv=>flag_changed
                       ) )
        MAPPED DATA(mapped)
        FAILED DATA(failed4)
        REPORTED DATA(reported4).

        MODIFY ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
        ENTITY _head
        UPDATE FIELDS ( SyncMsg )
          WITH VALUE #( ( %key-HeadID  = ls_detail-HeadID
                          SyncMsg = '尚未同步' ) )
        MAPPED DATA(mapped_copy)
        REPORTED DATA(reported_copy)
        FAILED DATA(failed_copy).

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD deleteItem.

    DATA: lt_update_h TYPE TABLE FOR UPDATE ztdguii_t_head,
          ls_update_h TYPE STRUCTURE FOR UPDATE ztdguii_t_head.

    READ ENTITIES OF  ZTDGUII_T_head IN LOCAL MODE
      ENTITY _detail
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_detail3).

    DATA : ls_detail_up TYPE STRUCTURE FOR UPDATE ZTDGUII_T_detail,
           lt_detail_up TYPE TABLE FOR UPDATE ZTDGUII_T_detail.

    LOOP AT lt_detail3 ASSIGNING FIELD-SYMBOL(<lf_detail>).
      <lf_detail>-statusmsg    = '已刪除'.
      <lf_detail>-criticality1 = 1.
      ls_detail_up-%control-statusmsg    = cl_abap_behv=>flag_changed.
      ls_detail_up-%control-criticality1 = cl_abap_behv=>flag_changed.
      MOVE-CORRESPONDING <lf_detail> TO ls_detail_up.
      APPEND ls_detail_up TO lt_detail_up.

      ls_update_h = VALUE #(  %key-HeadID = <lf_detail>-HeadID
                              %is_draft = '01'
                              SyncMsg = '尚未同步'
                              %control = VALUE #(
                              SyncMsg = cl_abap_behv=>flag_changed
                                                 ) ) .
      APPEND ls_update_h TO lt_update_h.

      CLEAR ls_detail_up.

    ENDLOOP.

    MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
    ENTITY _head
    UPDATE FROM lt_update_h
    ENTITY _detail
    UPDATE FROM lt_detail_up
    MAPPED DATA(mapped_h)
    FAILED DATA(failed_h)
    REPORTED DATA(reported_h).

    INSERT VALUE #(
     %msg = new_message_with_text(
     severity = if_abap_behv_message=>severity-information
              text     = |資料已上刪除註記，點擊SAVE確認刪除|
  ) ) INTO TABLE reported-_head.

  ENDMETHOD.

  METHOD updateStatus.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
    ENTITY _detail
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_detail_final).

    LOOP AT lt_detail_final INTO DATA(ls_detail_final).

      "檢查統一發票號碼===========================================
      IF ls_detail_final-Stceg IS INITIAL.
        DATA(l_msg) = '不完整'.
      ELSE.
        DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix( ).
        DATA(lv_case_insensitive_matches) = xco_cp=>string( ls_detail_final-stceg )->matches(
          iv_regular_expression = '^[0-9]{8}$'
          io_engine             = lo_posix_engine
        ).
        IF lv_case_insensitive_matches IS INITIAL.
          l_msg = '不完整'.
        ELSE.
          l_msg = '正常'.
        ENDIF.
      ENDIF.
      "==================================================

      MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
      ENTITY _detail
      UPDATE FIELDS ( statusmsg )
      WITH VALUE #( ( detailid  = ls_detail_final-detailid
                      HeadID    = ls_detail_final-HeadID
                      statusmsg = l_msg
                   %control-statusmsg = cl_abap_behv=>flag_changed
                   %is_draft = ls_detail_final-%is_draft
                     ) )
      MAPPED DATA(mapped)
      FAILED DATA(failed4)
      REPORTED DATA(reported4).

    ENDLOOP.

  ENDMETHOD.

  METHOD assignNumber.

    DATA l_numc_guinumber TYPE n LENGTH 12.
    DATA n1 TYPE i.
    DATA: lt_number TYPE TABLE OF znet_number_log,
          ls_number LIKE LINE OF lt_number.

    DATA: ls_update_d TYPE STRUCTURE FOR UPDATE ZTDGUII_T_detail,
          lt_update_d TYPE TABLE FOR UPDATE ZTDGUII_T_detail.

    DATA: ls_create_nl TYPE STRUCTURE FOR CREATE znei_number_log,
          lt_create_nl TYPE TABLE FOR CREATE znei_number_log.

***************************************************************
    READ ENTITIES OF ztdguii_t_head IN LOCAL MODE
    ENTITY _detail
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_detail_aenam)
    FAILED failed.

    LOOP AT lt_detail_aenam ASSIGNING FIELD-SYMBOL(<lfs_detail>).

      TRY.
          DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZTDGUI_NUMBER' ).
        CATCH cx_abap_lock_failure INTO DATA(exception).
          RAISE SHORTDUMP exception.
      ENDTRY.

      TRY.
          SELECT *
          FROM znet_number_log
          ORDER BY guinumber DESCENDING
          INTO @DATA(l_guinumber)
          UP TO 1 ROWS.
          ENDSELECT.

          l_numc_guinumber = l_guinumber-guinumber.
          l_numc_guinumber += 1.


*          lock_detail->enqueue(
          lock->enqueue(
              it_parameter = VALUE #( ( name = 'GUINUMBER' value = REF #( l_numc_guinumber ) ) )
           ).


          n1 = n1 + 1.
          ls_create_nl = VALUE #(
                                   %cid      = |HEAD_{ n1 }|
                                   Guinumber =  l_numc_guinumber
                                   %control  = VALUE #( Guinumber = cl_abap_behv=>flag_changed
                                ) ) .
          APPEND ls_create_nl TO lt_create_nl.

***************************************************************
          <lfs_detail>-aenam = l_numc_guinumber.
          ls_update_d-%control-aenam = cl_abap_behv=>flag_changed.

          MOVE-CORRESPONDING <lfs_detail> TO ls_update_d.

          APPEND ls_update_d TO lt_update_d.
          CLEAR ls_update_d.

        CATCH  cx_abap_foreign_lock INTO DATA(foreign_lock).

          APPEND VALUE #(

          HeadID = <lfs_detail>-HeadID
          DetailID = <lfs_detail>-DetailID
          %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     =  'Record is locked by ' && foreign_lock->user_name
                   )

           ) TO reported-_detail.

          APPEND VALUE #(
             HeadID = <lfs_detail>-HeadID
             DetailID = <lfs_detail>-DetailID
           ) TO failed-_detail.


        CATCH cx_abap_lock_failure INTO DATA(exception2).
          RAISE SHORTDUMP exception2.
      ENDTRY.

    ENDLOOP.

    MODIFY ENTITIES OF znei_number_log
    ENTITY numlog
    CREATE FROM lt_create_nl
    MAPPED DATA(mapped_nl)
    FAILED DATA(failed_nl)
    REPORTED DATA(reported_nl).

    IF failed_nl IS NOT INITIAL.
      LOOP AT lt_update_d ASSIGNING FIELD-SYMBOL(<lfs_detail_error_msg>).
        <lfs_detail_error_msg>-nummsg = 'Error Happend Try Again'.
        <lfs_detail_error_msg>-%control-nummsg = cl_abap_behv=>flag_changed.
      ENDLOOP.
    ELSE.
      LOOP AT lt_update_d ASSIGNING FIELD-SYMBOL(<lfs_detail_msg>).
        <lfs_detail_msg>-nummsg = '配號成功'.
        <lfs_detail_msg>-%control-nummsg = cl_abap_behv=>flag_changed.
      ENDLOOP.
    ENDIF.

    MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
    ENTITY _detail
    UPDATE FROM lt_update_d
    MAPPED DATA(mapped_h)
    FAILED DATA(failed_h)
    REPORTED DATA(reported_h).


  ENDMETHOD.

  METHOD cancelDelete.

    DATA: lt_update_h TYPE TABLE FOR UPDATE ztdguii_t_head,
          ls_update_h TYPE STRUCTURE FOR UPDATE ztdguii_t_head.

    READ ENTITIES OF  ZTDGUII_T_head IN LOCAL MODE
    ENTITY _detail
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_detail3).

    DATA : ls_detail_up TYPE STRUCTURE FOR UPDATE ZTDGUII_T_detail,
           lt_detail_up TYPE TABLE FOR UPDATE ZTDGUII_T_detail.

    LOOP AT lt_detail3 ASSIGNING FIELD-SYMBOL(<lf_detail>).

      "檢查統一發票號碼===========================================
      IF <lf_detail>-Stceg IS INITIAL.
        DATA(l_msg) = '不完整'.
        DATA(l_criticality) = 2.
      ELSE.
        DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix( ).
        DATA(lv_case_insensitive_matches) = xco_cp=>string( <lf_detail>-stceg )->matches(
          iv_regular_expression = '^[0-9]{8}$'
          io_engine             = lo_posix_engine
        ).
        IF lv_case_insensitive_matches IS INITIAL.
          l_msg = '不完整'.
          l_criticality = 2.
        ELSE.
          l_msg = '正常'.
          l_criticality = 3.
        ENDIF.
      ENDIF.
      "==================================================

      <lf_detail>-statusmsg    = l_msg.
      <lf_detail>-criticality1 = l_criticality.
      ls_detail_up-%control-statusmsg    = cl_abap_behv=>flag_changed.
      ls_detail_up-%control-criticality1 = cl_abap_behv=>flag_changed.
      MOVE-CORRESPONDING <lf_detail> TO ls_detail_up.
      APPEND ls_detail_up TO lt_detail_up.

      ls_update_h = VALUE #(  %key-HeadID = <lf_detail>-HeadID
                              %is_draft = '01'
                              SyncMsg = '尚未同步'
                              %control = VALUE #(
                              SyncMsg = cl_abap_behv=>flag_changed
                                                 ) ) .
      APPEND ls_update_h TO lt_update_h.

      CLEAR ls_detail_up.

    ENDLOOP.

    MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
    ENTITY _head
    UPDATE FROM lt_update_h
    ENTITY _detail
    UPDATE FROM lt_detail_up
    MAPPED DATA(mapped_h)
    FAILED DATA(failed_h)
    REPORTED DATA(reported_h).

  ENDMETHOD.

  METHOD hidecontrol.
    DATA : ls_detail_up TYPE STRUCTURE FOR UPDATE ZTDGUII_T_detail,
           lt_detail_up TYPE TABLE FOR UPDATE ZTDGUII_T_detail.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
      ENTITY _head
         ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
      ENTITY _detail
         ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_details).

    LOOP AT lt_details INTO DATA(ls_detail).

      IF ls_detail-Belnr = '1180000343'.
        MOVE-CORRESPONDING ls_detail TO ls_detail_up.
        APPEND ls_detail_up TO lt_detail_up.

      ELSEIF ls_detail-Belnr IS INITIAL.  "For Create 1180000343 New Item Instance

        READ TABLE lt_header INTO DATA(ls_header) INDEX 1.
        IF ls_header-Belnr = '1180000343'.
          MOVE-CORRESPONDING ls_detail TO ls_detail_up.
          APPEND ls_detail_up TO lt_detail_up.
        ENDIF.

      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
    ENTITY _detail
    UPDATE FIELDS (
                    Hidefield
                    Custname
                    Stceg
                              )
    WITH VALUE #( FOR ls_details IN lt_detail_up  INDEX INTO i (
                       %tky      = ls_details-%tky
                       Hidefield = 'X'
                       Custname  = 'TD_ABAP股份有限公司'
                       Stceg     = '55557777'
                 ) ).
  ENDMETHOD.

  METHOD changeArktx.

    DATA: lt_update_up TYPE TABLE FOR UPDATE ZTDGUII_T_detail,
          ls_update_up TYPE STRUCTURE FOR UPDATE ZTDGUII_T_detail.

    DATA: lt_update_h TYPE TABLE FOR UPDATE ztdguii_t_head,
          ls_update_h TYPE STRUCTURE FOR UPDATE ztdguii_t_head.

    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
      ENTITY _detail
         ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_details).

    LOOP AT lt_details ASSIGNING FIELD-SYMBOL(<lf_detail>).

      IF <lf_detail>-Custname = 'Neil_Company'.
        DATA(l_Arktx) = 'Neil_Goods'.

      ELSEIF <lf_detail>-Custname IS INITIAL.
        l_Arktx = ''.
      ENDIF.

      <lf_detail>-Arktx    = l_Arktx.
      ls_update_up-%control-Arktx = cl_abap_behv=>flag_changed.
      ls_update_up-%is_draft = '01'.

      MOVE-CORRESPONDING <lf_detail> TO ls_update_up.
      APPEND ls_update_up TO lt_update_up.
      CLEAR ls_update_up.

    ENDLOOP.

    MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
    ENTITY _detail
    UPDATE FROM lt_update_up
    MAPPED DATA(mapped76)
    FAILED DATA(failed76)
    REPORTED DATA(reported76).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
