CLASS lhc__head DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR _head RESULT result.

    METHODS getdata FOR MODIFY
      IMPORTING keys FOR ACTION _head~getdata RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR _head RESULT result.

    METHODS updatedata FOR MODIFY
      IMPORTING keys FOR ACTION _head~updatedata RESULT result.
*      IMPORTING keys FOR ACTION _head~updatedata.

    METHODS getdefaultsfor_neil FOR READ
      IMPORTING keys FOR FUNCTION _head~getdefaultsfor_neil RESULT result.

    METHODS recalctotal FOR MODIFY
      IMPORTING keys FOR ACTION _head~recalctotal.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK _head.

ENDCLASS.

CLASS lhc__head IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GetData.
    DATA ls_msg TYPE symsg.

    DATA: lt_head_check TYPE TABLE OF ZTDGUII_T_head.

    DATA: lt_detl_delete TYPE TABLE FOR DELETE ZTDGUII_T_detail,
          lt_head_delete TYPE TABLE FOR DELETE ZTDGUII_T_head.

    SELECT *
      FROM  ZTDGUII_T_head
      INTO CORRESPONDING FIELDS OF TABLE @lt_head_delete .

    SELECT *
      FROM ZTDGUII_T_detail
      INTO CORRESPONDING FIELDS OF TABLE @lt_detl_delete .

    IF lt_head_delete IS NOT INITIAL.
      MODIFY ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
       ENTITY _head
       DELETE FROM lt_head_delete
       ENTITY _detail
       DELETE FROM lt_detl_delete
       FAILED DATA(delete_failed)
       REPORTED DATA(delete_reported).
    ENDIF.

    TYPES : BEGIN OF ls_detail_sum,
              s_bas TYPE ztdguit_t_head-s_bas,
              s_ste TYPE ztdguit_t_head-s_ste,
              u_bas TYPE ztdguit_t_head-u_bas,
              u_ste TYPE ztdguit_t_head-u_ste,
              c_bas TYPE ztdguit_t_head-c_bas,
              c_ste TYPE ztdguit_t_head-c_ste,
            END OF ls_detail_sum.

    TRY.
        DATA(lo_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement(
                               comm_scenario   = 'ZNE_OUTBOUND_RFC_001_CSCEN'  " Communication scenario
                               service_id      = 'ZNE_OUTBOUND_RFC_001_SRFC'   " Outbound service
                               comm_system_id  = 'ZNE_OUTBOUND_RFC_CSYS'       " Communication system
                            ).

        DATA(lv_destination) = lo_destination->get_destination_name( ).

        DATA msg TYPE c LENGTH 255.

        DATA: lt_t_head     TYPE TABLE OF ztdguit_t_head,
              lt_t_detail   TYPE TABLE OF ztdguit_t_detail,
*              lt_t_detail   TYPE TABLE OF znet_guia02detl,
              lt_detail_sum TYPE TABLE OF ls_detail_sum.

        DATA(lp_bukrs)  = keys[ 1 ]-%param-bukrs.
        DATA(lp_gjahr)  = keys[ 1 ]-%param-gjahr.
        DATA(ls_budat)  = keys[ 1 ]-%param-budat.
        DATA(ls_budat2) = keys[ 1 ]-%param-budat2.
        DATA(lp_skip)   = keys[ 1 ]-%param-skip.
        DATA(lp_bkpf)   = keys[ 1 ]-%param-bkpf.
        DATA(ls_belnr)  = keys[ 1 ]-%param-belnr.
        DATA(ls_belnr2) = keys[ 1 ]-%param-belnrto.

        CALL FUNCTION 'YNE_GUIR015'
          DESTINATION lv_destination
          EXPORTING
            i_p_bukrs             = lp_bukrs
            i_p_gjahr             = lp_gjahr
            i_s_budat             = ls_budat
            i_s_budat2            = ls_budat2
            i_p_bkpf              = lp_bkpf
            i_p_skip              = lp_skip
            i_s_belnr             = ls_belnr
            i_s_belnr2            = ls_belnr2
          TABLES
            et_head               = lt_t_head
            et_guit11             = lt_t_detail
            et_sum                = lt_detail_sum
          EXCEPTIONS
            system_failure        = 1 MESSAGE msg
            communication_failure = 2 MESSAGE msg
            OTHERS                = 3.

        CASE sy-subrc.
          WHEN 0.

            DATA: n1 TYPE sy-tabix.
            DATA: n2 TYPE sy-tabix.
            DATA: lt_create_head TYPE TABLE FOR CREATE ztdguii_t_head,
                  ls_create_head TYPE STRUCTURE FOR CREATE ztdguii_t_head,
                  lt_create_detl TYPE TABLE FOR CREATE ztdguii_t_head\_detail,
                  ls_create_detl TYPE STRUCTURE FOR CREATE ztdguii_t_head\_detail.

            "+++++++++++++++++++++++++++++++++++++
*            DO 20 TIMES.
            "+++++++++++++++++++++++++++++++++++++

            LOOP AT lt_t_head INTO DATA(ls_t_head).
              DATA: l_tabix LIKE sy-tabix.
              l_tabix = sy-tabix.
              READ TABLE lt_detail_sum INTO DATA(ls_detail_sum) INDEX l_tabix.
              n1 = n1 + 1.


              "---GUIA02Head---
              ls_create_head = VALUE #(
              %cid = |HEAD_{ n1 }|
              SyncMsg    = '已同步'
              Bukrs      = ls_t_head-bukrs
              Belnr      = ls_t_head-Belnr
              Budat      = ls_t_head-Budat
              Bldat      = ls_t_head-Bldat
              Mwskz      = ls_t_head-Mwskz
              Hwbas      = ls_t_head-Hwbas
              Hwste      = ls_t_head-Hwste
              Hwbas2     = ls_t_head-Hwbas2
              Hwste2     = ls_t_head-Hwste2
              waers      = ls_t_head-waers
              Icon       = ls_t_head-Icon
              Icon2      = ls_t_head-Icon2
              Gjahr      = ls_t_head-Gjahr
              Blart      = ls_t_head-Blart
              Usnam      = ls_t_head-Usnam
              Awtyp      = ls_t_head-Awtyp
              Awkey      = ls_t_head-Awkey
              Stblg      = ls_t_head-Stblg
              SumFg      = ls_t_head-Sum_Fg
              Posflag    = ls_t_head-Posflag
              Manual     = ls_t_head-Manual
              Vbeln      = ls_t_head-Vbeln
              Vatcode    = ls_t_head-Vatcode
              Zform      = ls_t_head-Zform
              Copies     = ls_t_head-Copies
              Zexport    = ls_t_head-Zexport
              TaxType    = ls_t_head-Tax_Type
              TaxPer     = ls_t_head-Tax_Per
              AmType     = ls_t_head-Am_Type
              Notcheck   = ls_t_head-Notcheck
              CustFlag   = ls_t_head-Cust_Flag
              HwbasIndex = ls_t_head-Hwbas_Index
              HwsteIndex = ls_t_head-Hwste_Index
              BukrsIndex = ls_t_head-Bukrs_Index
              BelnrIndex = ls_t_head-Belnr_Index
              GjahrIndex = ls_t_head-Gjahr_Index
           ztdgui_module = ls_t_head-ztdgui_module
              Edigui     = ls_t_head-Edigui
              Canl       = ls_t_head-Canl
              SampleFg   = ls_t_head-Sample_Fg
              NetFg      = ls_t_head-Net_Fg
              s_bas      = ls_detail_sum-s_bas
              s_ste      = ls_detail_sum-s_ste
              u_bas      = ls_detail_sum-u_bas
              u_ste      = ls_detail_sum-u_ste
              c_bas      = ls_detail_sum-c_bas
              c_ste      = ls_detail_sum-c_ste
             %control = VALUE #(
              SyncMsg    = cl_abap_behv=>flag_changed
              Bukrs      = cl_abap_behv=>flag_changed
              Belnr      = cl_abap_behv=>flag_changed
              Budat      = cl_abap_behv=>flag_changed
              Bldat      = cl_abap_behv=>flag_changed
              Mwskz      = cl_abap_behv=>flag_changed
              Hwbas      = cl_abap_behv=>flag_changed
              Hwste      = cl_abap_behv=>flag_changed
              Hwbas2     = cl_abap_behv=>flag_changed
              Hwste2     = cl_abap_behv=>flag_changed
              waers      = cl_abap_behv=>flag_changed
              Icon       = cl_abap_behv=>flag_changed
              Icon2      = cl_abap_behv=>flag_changed
              Gjahr      = cl_abap_behv=>flag_changed
              Blart      = cl_abap_behv=>flag_changed
              Usnam      = cl_abap_behv=>flag_changed
              Awtyp      = cl_abap_behv=>flag_changed
              Awkey      = cl_abap_behv=>flag_changed
              Stblg      = cl_abap_behv=>flag_changed
              SumFg      = cl_abap_behv=>flag_changed
              Posflag    = cl_abap_behv=>flag_changed
              Manual     = cl_abap_behv=>flag_changed
              Vbeln      = cl_abap_behv=>flag_changed
              Vatcode    = cl_abap_behv=>flag_changed
              Zform      = cl_abap_behv=>flag_changed
              Copies     = cl_abap_behv=>flag_changed
              Zexport    = cl_abap_behv=>flag_changed
              TaxType    = cl_abap_behv=>flag_changed
              TaxPer     = cl_abap_behv=>flag_changed
              AmType     = cl_abap_behv=>flag_changed
              Notcheck   = cl_abap_behv=>flag_changed
              CustFlag   = cl_abap_behv=>flag_changed
              HwbasIndex = cl_abap_behv=>flag_changed
              HwsteIndex = cl_abap_behv=>flag_changed
              BukrsIndex = cl_abap_behv=>flag_changed
              BelnrIndex = cl_abap_behv=>flag_changed
              GjahrIndex = cl_abap_behv=>flag_changed
           ztdgui_module = cl_abap_behv=>flag_changed
              Edigui     = cl_abap_behv=>flag_changed
              Canl       = cl_abap_behv=>flag_changed
              SampleFg   = cl_abap_behv=>flag_changed
              NetFg      = cl_abap_behv=>flag_changed
              s_bas      = cl_abap_behv=>flag_changed
              s_ste      = cl_abap_behv=>flag_changed
              u_bas      = cl_abap_behv=>flag_changed
              u_ste      = cl_abap_behv=>flag_changed
              c_bas      = cl_abap_behv=>flag_changed
              c_ste      = cl_abap_behv=>flag_changed
                ) ).
              APPEND ls_create_head TO lt_create_head.

              "+++++++++++++++++++++++++++++++++++++
*              DO 2500 TIMES.
                "+++++++++++++++++++++++++++++++++++++
                LOOP AT lt_t_detail INTO DATA(ls_t_detail).

                  IF ls_t_detail-bukrs = ls_t_head-bukrs AND
                     ls_t_detail-belnr = ls_t_head-belnr AND
                     ls_t_detail-gjahr = ls_t_head-gjahr .

                    DATA(l_no) = 1.

                    n2 = n2 + 1.

                    IF ls_t_detail-stceg IS INITIAL.
                      DATA(l_statusmsg) = '不完整'.
                    ELSE.
                      l_statusmsg = '正常'.
                    ENDIF.

                    ls_create_detl = VALUE #(
                                     %cid_ref = |HEAD_{ n1 }|
                                     %target = VALUE #( (
                                               %cid = |DETAIL_{ n2 }|
                                               itemno         = ls_t_detail-Zaehl
                                               Bukrs          = ls_t_detail-Bukrs
                                               Belnr          = ls_t_detail-Belnr
                                               Gjahr          = ls_t_detail-Gjahr
                                               Zaehl          = ls_t_detail-Zaehl
                                               Xblnr          = ls_t_detail-Xblnr
                                               Xjahr          = ls_t_detail-Xjahr
                                               Bldat          = ls_t_detail-Bldat
                                               Vatdate        = ls_t_detail-Vatdate
                                               Hwbas          = ls_t_detail-Hwbas
                                               Hwste          = ls_t_detail-Hwste
                                               OfFlag         = ls_t_detail-Of_Flag
                                               HwbasOf        = ls_t_detail-Hwbas_Of
                                               HwsteOf        = ls_t_detail-Hwste_Of
                                               Stceg          = ls_t_detail-Stceg
                                               Zform_Code      = ls_t_detail-Zform_Code
                                               Am_Type         = ls_t_detail-Am_Type
                                               Tax_Type        = ls_t_detail-Tax_Type
                                               Zexport        = ls_t_detail-Zexport
                                               DivFlag        = ls_t_detail-Div_Flag
                                               Copies         = ls_t_detail-Copies
                                               CustFlag       = ls_t_detail-Cust_Flag
                                               Custname       = ls_t_detail-Custname
                                               Arktx          = ls_t_detail-Arktx
                                               Menge          = ls_t_detail-Menge
                                               NonCustomsName = ls_t_detail-Non_Customs_Name
                                               NonCustomsNo   = ls_t_detail-Non_Customs_No
                                               CustomsType    = ls_t_detail-Customs_Type
                                               CustomsNo      = ls_t_detail-Customs_No
                                               CustomsDate    = ls_t_detail-Customs_Date
                                               Awtyp          = ls_t_detail-Awtyp
                                               Awkey          = ls_t_detail-Awkey
                                               Vbeln          = ls_t_detail-Vbeln
                                               Fkart          = ls_t_detail-Fkart
                                               Fkdat          = ls_t_detail-Fkdat
                                               Aubel          = ls_t_detail-Aubel
                                               Loekz          = ls_t_detail-Loekz
                                               Canl           = ls_t_detail-Canl
                                               Vatcode        = ls_t_detail-Vatcode
                                               Notcheck       = ls_t_detail-Notcheck
                                               Pupflag        = ls_t_detail-Pupflag
                                               Autoflag       = ls_t_detail-Autoflag
                                               Ernam          = ls_t_detail-Ernam
                                               Erdat          = ls_t_detail-Erdat
                                               Erzet          = ls_t_detail-Erzet
                                               Aenam          = ls_t_detail-Aenam
                                               Aedat          = ls_t_detail-Aedat
                                               DescColl       = ls_t_detail-Desc_Coll
                                               History        = ls_t_detail-History
                                               Kunnr          = ls_t_detail-Kunnr
                                               PtrFg          = ls_t_detail-Ptr_Fg
                                               Remark         = ls_t_detail-Remark
                                               Crserialno     = ls_t_detail-Crserialno
                                               Mwskz          = ls_t_detail-Mwskz
                                               Seq            = ls_t_detail-Seq
                                               CrDesc         = ls_t_detail-Cr_Desc
                                               CrQty          = ls_t_detail-Cr_Qty
                                               CrPrice        = ls_t_detail-Cr_Price
                                               ReuseFg        = ls_t_detail-Reuse_Fg
                                               CopyFg         = ls_t_detail-Copy_Fg
                                               Notvat         = ls_t_detail-Notvat
                                               XblnrF         = ls_t_detail-Xblnr_F
                                               Lgort          = ls_t_detail-Lgort
                                               CashRegSnum    = ls_t_detail-Cash_Reg_Snum
                                               Posflag        = ls_t_detail-Posflag
                                               XblnrEnd       = ls_t_detail-Xblnr_End
                                               CrNo           = ls_t_detail-Cr_No
                                               VatdateCr      = ls_t_detail-Vatdate_Cr
                                               CollCanlDate   = ls_t_detail-Coll_Canl_Date
                                               CollCanlTime   = ls_t_detail-Coll_Canl_Time
                                               CollFg         = ls_t_detail-Coll_Fg
                                               Mblnr          = ls_t_detail-Mblnr
                                               SeqPresales    = ls_t_detail-Seq_Presales
                                               Matnr          = ls_t_detail-Matnr
                                               Ptr            = ls_t_detail-Ptr
                                               Vrkme          = ls_t_detail-Vrkme
                                               Posnr          = ls_t_detail-Posnr
                                               StoFg          = ls_t_detail-Sto_Fg
                                               Budat          = ls_t_detail-Budat
                                               ManlFg         = ls_t_detail-Manl_Fg
                                               X2b2Fg         = ls_t_detail-X2b2_Fg
                                               B2Fg           = ls_t_detail-B2_Fg
                                               B2Doc          = ls_t_detail-B2_Doc
                                               X2Fg           = ls_t_detail-X2_Fg
                                               X2Doc          = ls_t_detail-X2_Doc
                                               VbelnVl        = ls_t_detail-Vbeln_Vl
                                               Mjahr          = ls_t_detail-Mjahr
                                               Vfcod          = ls_t_detail-Vfcod
                                               Carriertype    = ls_t_detail-Carriertype
                                               Carrierid1     = ls_t_detail-Carrierid1
                                               Carrierid2     = ls_t_detail-Carrierid2
                                               Donatemark     = ls_t_detail-Donatemark
                                               Donatetarget   = ls_t_detail-Donatetarget
                                               CanlDate       = ls_t_detail-Canl_Date
                                               CanlTime       = ls_t_detail-Canl_Time
                                               CanlFlag       = ls_t_detail-Canl_Flag
                                               PreSo          = ls_t_detail-Pre_So
                                               Edigui         = ls_t_detail-Edigui
                                               VoID           = ls_t_detail-VoID
                                               Voiddate       = ls_t_detail-Voiddate
                                               Voidtime       = ls_t_detail-Voidtime
                                               InOutbound     = ls_t_detail-In_Outbound
                                               Eguitype       = ls_t_detail-Eguitype
                                               EcrFlag        = ls_t_detail-Ecr_Flag
                                               Msatz          = ls_t_detail-Msatz
                                               Stblg          = ls_t_detail-Stblg
                                               Stjah          = ls_t_detail-Stjah
                                               waers          = ls_t_head-waers
                                               statusmsg      = l_statusmsg
                                    %control = VALUE #(
                                       itemno          = cl_abap_behv=>flag_changed
                                       Bukrs           = cl_abap_behv=>flag_changed
                                       Belnr           = cl_abap_behv=>flag_changed
                                       Gjahr           = cl_abap_behv=>flag_changed
                                       Zaehl           = cl_abap_behv=>flag_changed
                                       Xblnr           = cl_abap_behv=>flag_changed
                                       Xjahr           = cl_abap_behv=>flag_changed
                                       Bldat           = cl_abap_behv=>flag_changed
                                       Vatdate         = cl_abap_behv=>flag_changed
                                       Hwbas           = cl_abap_behv=>flag_changed
                                       Hwste           = cl_abap_behv=>flag_changed
                                       OfFlag          = cl_abap_behv=>flag_changed
                                       HwbasOf         = cl_abap_behv=>flag_changed
                                       HwsteOf         = cl_abap_behv=>flag_changed
                                       Stceg           = cl_abap_behv=>flag_changed
                                       Zform_Code       = cl_abap_behv=>flag_changed
                                       Am_Type          = cl_abap_behv=>flag_changed
                                       Tax_Type         = cl_abap_behv=>flag_changed
                                       Zexport         = cl_abap_behv=>flag_changed
                                       DivFlag         = cl_abap_behv=>flag_changed
                                       Copies          = cl_abap_behv=>flag_changed
                                       CustFlag        = cl_abap_behv=>flag_changed
                                       Custname        = cl_abap_behv=>flag_changed
                                       Arktx           = cl_abap_behv=>flag_changed
                                       Menge           = cl_abap_behv=>flag_changed
                                       NonCustomsName  = cl_abap_behv=>flag_changed
                                       NonCustomsNo    = cl_abap_behv=>flag_changed
                                       CustomsType     = cl_abap_behv=>flag_changed
                                       CustomsNo       = cl_abap_behv=>flag_changed
                                       CustomsDate     = cl_abap_behv=>flag_changed
                                       Awtyp           = cl_abap_behv=>flag_changed
                                       Awkey           = cl_abap_behv=>flag_changed
                                       Vbeln           = cl_abap_behv=>flag_changed
                                       Fkart           = cl_abap_behv=>flag_changed
                                       Fkdat           = cl_abap_behv=>flag_changed
                                       Aubel           = cl_abap_behv=>flag_changed
                                       Loekz           = cl_abap_behv=>flag_changed
                                       Canl            = cl_abap_behv=>flag_changed
                                       Vatcode         = cl_abap_behv=>flag_changed
                                       Notcheck        = cl_abap_behv=>flag_changed
                                       Pupflag         = cl_abap_behv=>flag_changed
                                       Autoflag        = cl_abap_behv=>flag_changed
                                       Ernam           = cl_abap_behv=>flag_changed
                                       Erdat           = cl_abap_behv=>flag_changed
                                       Erzet           = cl_abap_behv=>flag_changed
                                       Aenam           = cl_abap_behv=>flag_changed
                                       Aedat           = cl_abap_behv=>flag_changed
                                       DescColl        = cl_abap_behv=>flag_changed
                                       History         = cl_abap_behv=>flag_changed
                                       Kunnr           = cl_abap_behv=>flag_changed
                                       PtrFg           = cl_abap_behv=>flag_changed
                                       Remark          = cl_abap_behv=>flag_changed
                                       Crserialno      = cl_abap_behv=>flag_changed
                                       Mwskz           = cl_abap_behv=>flag_changed
                                       Seq             = cl_abap_behv=>flag_changed
                                       CrDesc          = cl_abap_behv=>flag_changed
                                       CrQty           = cl_abap_behv=>flag_changed
                                       CrPrice         = cl_abap_behv=>flag_changed
                                       ReuseFg         = cl_abap_behv=>flag_changed
                                       CopyFg          = cl_abap_behv=>flag_changed
                                       Notvat          = cl_abap_behv=>flag_changed
                                       XblnrF          = cl_abap_behv=>flag_changed
                                       Lgort           = cl_abap_behv=>flag_changed
                                       CashRegSnum     = cl_abap_behv=>flag_changed
                                       Posflag         = cl_abap_behv=>flag_changed
                                       XblnrEnd        = cl_abap_behv=>flag_changed
                                       CrNo            = cl_abap_behv=>flag_changed
                                       VatdateCr       = cl_abap_behv=>flag_changed
                                       CollCanlDate    = cl_abap_behv=>flag_changed
                                       CollCanlTime    = cl_abap_behv=>flag_changed
                                       CollFg          = cl_abap_behv=>flag_changed
                                       Mblnr           = cl_abap_behv=>flag_changed
                                       SeqPresales     = cl_abap_behv=>flag_changed
                                       Matnr           = cl_abap_behv=>flag_changed
                                       Ptr             = cl_abap_behv=>flag_changed
                                       Vrkme           = cl_abap_behv=>flag_changed
                                       Posnr           = cl_abap_behv=>flag_changed
                                       StoFg           = cl_abap_behv=>flag_changed
                                       Budat           = cl_abap_behv=>flag_changed
                                       ManlFg          = cl_abap_behv=>flag_changed
                                       X2b2Fg          = cl_abap_behv=>flag_changed
                                       B2Fg            = cl_abap_behv=>flag_changed
                                       B2Doc           = cl_abap_behv=>flag_changed
                                       X2Fg            = cl_abap_behv=>flag_changed
                                       X2Doc           = cl_abap_behv=>flag_changed
                                       VbelnVl         = cl_abap_behv=>flag_changed
                                       Mjahr           = cl_abap_behv=>flag_changed
                                       Vfcod           = cl_abap_behv=>flag_changed
                                       Carriertype     = cl_abap_behv=>flag_changed
                                       Carrierid1      = cl_abap_behv=>flag_changed
                                       Carrierid2      = cl_abap_behv=>flag_changed
                                       Donatemark      = cl_abap_behv=>flag_changed
                                       Donatetarget    = cl_abap_behv=>flag_changed
                                       CanlDate        = cl_abap_behv=>flag_changed
                                       CanlTime        = cl_abap_behv=>flag_changed
                                       CanlFlag        = cl_abap_behv=>flag_changed
                                       PreSo           = cl_abap_behv=>flag_changed
                                       Edigui          = cl_abap_behv=>flag_changed
                                       VoID            = cl_abap_behv=>flag_changed
                                       Voiddate        = cl_abap_behv=>flag_changed
                                       Voidtime        = cl_abap_behv=>flag_changed
                                       InOutbound      = cl_abap_behv=>flag_changed
                                       Eguitype        = cl_abap_behv=>flag_changed
                                       EcrFlag         = cl_abap_behv=>flag_changed
                                       Msatz           = cl_abap_behv=>flag_changed
                                       Stblg           = cl_abap_behv=>flag_changed
                                       Stjah           = cl_abap_behv=>flag_changed
                                       waers           = cl_abap_behv=>flag_changed
                                       statusmsg       = cl_abap_behv=>flag_changed

                                                           ) ) ) ).
                    APPEND ls_create_detl TO lt_create_detl.
                  ENDIF.

                ENDLOOP.
                "+++++++++++++++++++++++++++++++++++++
*              ENDDO.
              "+++++++++++++++++++++++++++++++++++++

            ENDLOOP.

            "+++++++++++++++++++++++++++++++++++++
*            ENDDO.
            "+++++++++++++++++++++++++++++++++++++

            MODIFY ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
             ENTITY _head
             CREATE FROM lt_create_head
             CREATE BY \_detail
             FROM lt_create_detl
             MAPPED DATA(mapped_a02)
             REPORTED DATA(reported_a02)
             FAILED DATA(failed_a02).

            INSERT VALUE #(
                   %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-information
                      text     = |資料已更新!! 請重整頁面或點擊'GO'按鈕|
                      )
            ) INTO TABLE reported-_head.

          WHEN 1.
*            out->write( |EXCEPTION SYSTEM_FAILURE | && msg ).
*          WHEN 2.
*            out->write( |EXCEPTION COMMUNICATION_FAILURE | && msg ).
*          WHEN 3.
*            out->write( |EXCEPTION OTHERS| ).
        ENDCASE.

      CATCH cx_root INTO DATA(lx_root).
*        out->write(  lx_root->get_longtext( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_instance_features.
    DATA:
      l_currecycode TYPE ZTDGUII_T_head-waers,
      l_S_BAS       TYPE ZTDGUII_T_head-Hwbas,
      l_S_STE       TYPE ZTDGUII_T_head-Hwste,
      l_U_BAS       TYPE ZTDGUII_T_detail-Hwbas,
      l_U_STE       TYPE ZTDGUII_T_detail-Hwste,
      l_C_BAS       TYPE ZTDGUII_T_detail-Hwbas,
      l_C_STE       TYPE ZTDGUII_T_detail-Hwste.
    DATA l_headid TYPE ZTDGUITD_detail-headid.
    DATA(l_flag) = 1.
    DATA: lt_update_h TYPE TABLE FOR UPDATE ztdguii_t_head,
          ls_update_h TYPE STRUCTURE FOR UPDATE ztdguii_t_head.

    "Read Head instances
    READ ENTITIES OF ZTDGUII_T_head IN LOCAL MODE
    ENTITY _head
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_heads)
    FAILED failed.

    result = VALUE #( FOR ls_head_ins IN lt_heads
                      ( %tky = ls_head_ins-%tky
                        %action-UpdateData
                          = COND #( WHEN ls_head_ins-SyncMsg = '已同步'
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )
                        ) ).

  ENDMETHOD.

  METHOD UpdateData.

    INSERT VALUE #(
           %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-warning
              text     = |R U SURE?|
              )
    ) INTO TABLE reported-_head.

  ENDMETHOD.

  METHOD GetDefaultsFor_neil.

    APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<fs_result>).
    <fs_result>-%param-budat = '20230101'.
    <fs_result>-%param-budat2 = sy-datum.
    <fs_result>-%param-bukrs = if_abap_behv=>fc-f-read_only.
  ENDMETHOD.

  METHOD ReCalcTotal.
    DATA:
      l_currecycode TYPE ZTDGUII_T_head-waers,
      l_S_BAS       TYPE ZTDGUII_T_head-Hwbas,
      l_S_STE       TYPE ZTDGUII_T_head-Hwste,
      l_U_BAS       TYPE ZTDGUII_T_detail-Hwbas,
      l_U_STE       TYPE ZTDGUII_T_detail-Hwste,
      l_C_BAS       TYPE ZTDGUII_T_detail-Hwbas,
      l_C_STE       TYPE ZTDGUII_T_detail-Hwste,
      lV_S_BAS      TYPE ZTDGUII_T_head-Hwbas,
      lV_S_STE      TYPE ZTDGUII_T_head-Hwste,
      lV_U_BAS      TYPE ZTDGUII_T_detail-Hwbas,
      lV_U_STE      TYPE ZTDGUII_T_detail-Hwste,
      lV_C_BAS      TYPE ZTDGUII_T_detail-Hwbas,
      lV_C_STE      TYPE ZTDGUII_T_detail-Hwste.
    DATA: ls_head TYPE STRUCTURE FOR UPDATE ZTDGUII_T_head,
          lt_head TYPE TABLE FOR UPDATE  ZTDGUII_T_head.

    READ ENTITIES OF  ZTDGUII_T_head
    IN LOCAL MODE
    ENTITY _head
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_total_H)

    ENTITY  _head BY \_detail
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_total_D).

    l_currecycode = VALUE #( lt_total_h[ 1 ]-waers OPTIONAL ).
    IF lt_total_H[ 1 ]-belnr = lt_total_H[ 1 ]-BukrsIndex.
      l_s_bas = lt_total_H[ 1 ]-HwbasIndex.
      l_s_STE = lt_total_H[ 1 ]-HwsteIndex.
    ELSE.
      l_s_bas = lt_total_H[ 1 ]-Hwbas.
      l_s_STE = lt_total_H[ 1 ]-Hwste.
    ENDIF.

    IF lt_total_D IS NOT INITIAL.
      LOOP AT lt_total_D ASSIGNING FIELD-SYMBOL(<fs_total_d>) WHERE canl = ''.
        CASE <fs_total_d>-Zform_Code.
          WHEN 31 OR 32 OR 35 OR 36 OR 37.
            l_u_bas += <fs_total_d>-hwbas.
            l_u_ste += <fs_total_d>-hwste.

          WHEN 33 OR 34 OR 38.
            l_c_bas = l_c_bas - <fs_total_d>-hwbas.
            l_c_ste = l_c_ste - <fs_total_d>-hwste.
        ENDCASE.

      ENDLOOP.
    ENDIF.

    lt_total_h[ 1 ]-s_bas = l_s_bas.

    lt_total_h[ 1 ]-s_ste =  l_s_STE.

    lt_total_h[ 1 ]-u_bas = l_u_bas.
    lt_total_h[ 1 ]-u_ste = l_u_ste.
    lt_total_h[ 1 ]-c_bas = l_c_bas.
    lt_total_h[ 1 ]-c_ste = l_c_ste.

    MOVE-CORRESPONDING lt_total_h[ 1 ] TO ls_head.

    APPEND ls_head TO lt_head.

    MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
    ENTITY _head
    UPDATE FROM lt_head
     MAPPED DATA(mapped3)
     FAILED DATA(failed3)
     REPORTED DATA(reported4).
    MODIFY ENTITIES OF ZTDGUII_T_head  IN LOCAL MODE
    ENTITY _head
    UPDATE FIELDS ( s_bas s_ste u_bas u_ste c_bas c_ste )
    WITH VALUE #( ( %key = lt_total_h[ 1 ]-%key
                    %is_draft = 00 "lt_total_h[ 1 ]-%is_draft
                     s_bas = l_s_bas
                     s_ste = l_s_STE
                     u_bas = l_u_bas
                     u_ste = l_u_ste
                     c_bas = l_c_bas
                     c_ste = l_c_ste

                       ) ).

  ENDMETHOD.

  METHOD lock.

    READ ENTITIES OF ztdguii_t_head IN LOCAL MODE
    ENTITY _head
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_detail_aenam).

    DATA: l_belnr TYPE ztdguit_t_head-belnr.
    DATA: l_headid TYPE ztdguit_t_head-headid,
          l_user   TYPE syst-uname.
    DATA: BEGIN OF ls_lock,
            belnr  TYPE ztdguit_t_head-belnr,
            l_user TYPE syst-uname,
          END OF ls_lock.
    LOOP AT lt_detail_aenam ASSIGNING FIELD-SYMBOL(<fs_head>).

      l_belnr  =  <fs_head>-Belnr.
      l_user   = syst-uname.
      l_headid  =  <fs_head>-headid.
      TRY.
          DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZTDGUI_T_HEAD2' ).
        CATCH cx_abap_lock_failure INTO DATA(exception).
          RAISE SHORTDUMP exception.
      ENDTRY.

*      TRY.
*          DATA(lock2) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZCHT_LOCKTEST' ).
*        CATCH cx_abap_lock_failure INTO DATA(exception3).
*          RAISE SHORTDUMP exception3.
*      ENDTRY.

      TRY.
          lock->enqueue(
*              it_parameter = VALUE #( ( name = 'BELNR' value = REF #( l_belnr ) ) )
              it_parameter = VALUE #( ( name = 'HEADID' value = REF #( l_headid ) ) )
           ).
        CATCH  cx_abap_foreign_lock INTO DATA(foreign_lock).

          APPEND VALUE #(

          HeadID = <fs_head>-HeadID
          %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     =  'Record is locked by' && foreign_lock->user_name
                   )

           ) TO reported-_head.
          APPEND VALUE #(

             HeadID = <fs_head>-HeadID
           ) TO failed-_head.


        CATCH cx_abap_lock_failure INTO DATA(exception2).
          RAISE SHORTDUMP exception2.
      ENDTRY.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
