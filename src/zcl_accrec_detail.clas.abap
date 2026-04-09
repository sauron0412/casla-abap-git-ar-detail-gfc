CLASS zcl_accrec_detail DEFINITION
  PUBLIC
  FINAL

    INHERITING FROM cx_rap_query_provider

  CREATE PUBLIC .
  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.

    " Define line item structure internally
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,
           BEGIN OF lty_text,
             billing  TYPE vbeln,
             outbound TYPE vbeln,
             belnr    TYPE belnr_d,
             text     TYPE c LENGTH 2000,
           END OF lty_text,

           tt_text   TYPE TABLE OF lty_text,

           tt_ranges TYPE TABLE OF ty_range_option.

    TYPES: BEGIN OF ty_returns,
             msgty TYPE symsgty,  "char(1) Message Type
             msgid TYPE symsgid,  "char(20) Message Class
             msgno TYPE symsgno,  "numc(3) Message Number
             msgv1 TYPE symsgv,   "char(50) Message Variable
             msgv2 TYPE symsgv,   "char(50) Message Variable
             msgv3 TYPE symsgv,   "char(50) Message Variable
             msgv4 TYPE symsgv,
           END OF ty_returns,

           tt_returns TYPE STANDARD TABLE OF ty_returns WITH EMPTY KEY.

    DATA: gt_ttusd TYPE TABLE OF zc_ttusd.
    TYPES: BEGIN OF ty_line_item,
             posting_date        TYPE budat,
             document_number     TYPE belnr_d,
             document_date       TYPE bldat,
             contra_account      TYPE saknr,
             item_text           TYPE sgtxt,
             profit_center       TYPE prctr,
             debit_amount        TYPE wrbtr,
             credit_amount       TYPE wrbtr,
             balance             TYPE wrbtr,
             closingdebit        TYPE wrbtr,
             closingcredit       TYPE wrbtr,
             debit_amount_tran   TYPE wrbtr,
             credit_amount_tran  TYPE wrbtr,
             balance_tran        TYPE wrbtr,
             closingdebit_tran   TYPE wrbtr,
             closingcredit_tran  TYPE wrbtr,
             companycodecurrency TYPE waers,
             transactioncurrency TYPE waers,
             thanhtoannt         TYPE char1,
           END OF ty_line_item.

    TYPES: ty_ledgergllineitem TYPE c LENGTH 6.

    TYPES: tt_line_items TYPE TABLE OF ty_line_item.

    TYPES: BEGIN OF ty_journal_item,
             companycode                    TYPE bukrs,
             fiscalyear                     TYPE gjahr,
             accountingdocument             TYPE belnr_d,
             accountingdocumentitem         TYPE buzei,
             glaccount                      TYPE saknr,
             isreversed                     TYPE i_journalentryitem-isreversed,
             reversalreferencedocument      TYPE i_journalentryitem-reversalreferencedocument,
             reversalreferencedocumentcntxt TYPE i_journalentryitem-reversalreferencedocumentcntxt,
             ledgergllineitem               TYPE ty_ledgergllineitem,
             postingdate                    TYPE budat,
             documentdate                   TYPE bldat,
             customer                       TYPE kunnr,
             amountincompanycodecurrency    TYPE wrbtr,
             amountintransactioncurrency    TYPE wrbtr,
             debitcreditcode                TYPE shkzg,
             accountingdocumenttype         TYPE blart,
             documentitemtext               TYPE sgtxt,
             addtext2                       TYPE c LENGTH 40,
             profitcenter                   TYPE prctr,
             companycodecurrency            TYPE waers,
             transactioncurrency            TYPE waers,
             financialaccounttype           TYPE i_journalentryitem-financialaccounttype,
             clearingaccountingdocument     TYPE i_journalentryitem-clearingaccountingdocument,
             offsettingaccounttype          TYPE i_journalentryitem-offsettingaccounttype,
             subledgeracctlineitemtype      TYPE i_journalentryitem-subledgeracctlineitemtype,
           END OF ty_journal_item.

    TYPES: tt_journal_items TYPE TABLE OF ty_journal_item,
           tt_open_balances TYPE TABLE OF zst_open_balances.

    TYPES: BEGIN OF ty_in_faglfcv,
             ccode           TYPE zui_in_faglfcv-ccode,
             account         TYPE zui_in_faglfcv-account,
             gl_account      TYPE zui_in_faglfcv-gl_account,
             doc_number      TYPE zui_in_faglfcv-doc_number,
             keydate         TYPE zui_in_faglfcv-keydate,
             debit_faglfcv   TYPE zui_in_faglfcv-posting_amount,
             credit_faglfcv  TYPE zui_in_faglfcv-posting_amount,
             currency        TYPE zui_in_faglfcv-currency,
             target_currency TYPE zui_in_faglfcv-target_currency,
           END OF ty_in_faglfcv,

           tt_in_faglfcv TYPE TABLE OF ty_in_faglfcv.

    METHODS get_company_info
      IMPORTING iv_bukrs           TYPE bukrs
      EXPORTING ev_company_name    TYPE text100
                ev_company_address TYPE char256.

    METHODS get_business_partner_name
      IMPORTING iv_business_partner TYPE text10
      RETURNING VALUE(rv_name)      TYPE text100.

    METHODS get_opening_balance
      IMPORTING iv_bukrs         TYPE bukrs
                iv_racct         TYPE saknr
                iv_partner       TYPE text10
                iv_date          TYPE datum
                iv_currency      TYPE waers
                iv_currency_para TYPE waers
      EXPORTING ev_debit         TYPE wrbtr
                ev_credit        TYPE wrbtr
                ev_balance       TYPE wrbtr
                ev_debit_tran    TYPE wrbtr
                ev_credit_tran   TYPE wrbtr
                ev_balance_tran  TYPE wrbtr
                tt_open_balances TYPE tt_open_balances
                ev_thanhtoan     TYPE char1..

    METHODS process_period_data
      IMPORTING it_journal_items     TYPE tt_journal_items
                it_open_balances     TYPE tt_open_balances
                it_in_faglfcv        TYPE tt_in_faglfcv
                iv_bukrs             TYPE bukrs
                iv_racct             TYPE saknr
                iv_partner           TYPE text10
                iv_date_from         TYPE datum
                iv_date_to           TYPE datum
                iv_currency          TYPE waers
      EXPORTING et_line_items        TYPE tt_line_items
                ev_debit_total       TYPE wrbtr
                ev_credit_total      TYPE wrbtr
                ev_debit_total_tran  TYPE wrbtr
                ev_credit_total_tran TYPE wrbtr.

    METHODS get_contra_account
      IMPORTING iv_bukrs                  TYPE bukrs
                iv_accountingdoc          TYPE belnr_d
                iv_fiscalyear             TYPE gjahr
                iv_racct                  TYPE saknr
                iv_lineitem               TYPE ty_ledgergllineitem
                iv_accountingdocumentitem TYPE buzei
      RETURNING VALUE(rv_contra)          TYPE saknr.

    METHODS get_longtext_outbound IMPORTING tt_text_i TYPE tt_text
                                  EXPORTING tt_text_o TYPE tt_text.

    METHODS determine_account_nature
      IMPORTING iv_glaccount     TYPE saknr
      RETURNING VALUE(rv_nature) TYPE char1_run_type.

    METHODS convert_line_items_to_json
      IMPORTING it_line_items  TYPE tt_line_items
      RETURNING VALUE(rv_json) TYPE string.

ENDCLASS.



CLASS ZCL_ACCREC_DETAIL IMPLEMENTATION.


  METHOD convert_line_items_to_json.
    " Convert internal table to JSON string
    DATA: lo_writer TYPE REF TO cl_sxml_string_writer.

    lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    CALL TRANSFORMATION id
      SOURCE line_items = it_line_items
      RESULT XML lo_writer.

    rv_json = cl_abap_conv_codepage=>create_in( )->convert( lo_writer->get_output( ) ).

  ENDMETHOD.


  METHOD determine_account_nature.
    " Determine if account is debit or credit nature based on GL account number
    DATA: lv_first_char TYPE c LENGTH 1,
          lv_first_two  TYPE c LENGTH 2,
          lv_first_four TYPE c LENGTH 4.

    " remove leading zeros for accurate classification
    DATA(lv_glaccount) = |{ iv_glaccount ALPHA = OUT  }|.
    lv_first_char = lv_glaccount(1).
    lv_first_two = lv_glaccount(2).
    lv_first_four = lv_glaccount(4).


    " Special handling for certain accounts
    IF lv_first_four = '1312'.
      rv_nature = 'C'. " Credit nature
      RETURN.
    ELSEIF lv_first_four = '3312'.
      rv_nature = 'D'. " Debit nature
      RETURN.
    ENDIF.

    " Standard account classification
    IF lv_first_char = '1' OR lv_first_char = '2' OR
       lv_first_char = '6' OR lv_first_char = '8' OR
       lv_first_two = 'Z1'.
      rv_nature = 'D'. " Debit nature (Assets, Expenses)
    ELSE.
      rv_nature = 'C'. " Credit nature (Liabilities, Revenue, Equity)
    ENDIF.

  ENDMETHOD.


  METHOD get_business_partner_name.
    DATA: lv_name TYPE string.

    " First try to get from I_BusinessPartner
    SELECT SINGLE businesspartnername
      FROM i_businesspartner
      WHERE businesspartner = @iv_business_partner
      INTO @lv_name.

    IF lv_name IS NOT INITIAL.
      rv_name = lv_name.
      RETURN.
    ENDIF.

    " If not found, try customer master
    SELECT SINGLE customername
      FROM i_customer
      WHERE customer = @iv_business_partner
      INTO @lv_name.

    IF lv_name IS NOT INITIAL.
      rv_name = lv_name.
      RETURN.
    ENDIF.

    " If still not found, try supplier master
    SELECT SINGLE suppliername
      FROM i_supplier
      WHERE supplier = @iv_business_partner
      INTO @lv_name.

    IF lv_name IS NOT INITIAL.
      rv_name = lv_name.
      RETURN.
    ENDIF.

    " If still nothing found, return the BP number
    rv_name = |BP: { iv_business_partner }|.

  ENDMETHOD.


  METHOD get_company_info.
    SELECT SINGLE
              companycode,
              addressid,
              vatregistration,
              currency,
              companycodename
    FROM i_companycode
    WHERE companycode = @iv_bukrs
    INTO @DATA(ls_company).
    .

    zcl_jp_common_core=>get_address_id_details(
      EXPORTING
        addressid          = ls_company-addressid
      IMPORTING
        o_addressiddetails = DATA(ls_addressid_dtails)
    ).

    ev_company_name = ls_company-companycodename.
*    ev_company_address = ls_addressid_dtails-address.

  ENDMETHOD.


  METHOD get_contra_account.
    " Get other line items from the same document
    SELECT SINGLE glaccount, amountincompanycodecurrency
      FROM i_glaccountlineitem
      WHERE companycode = @iv_bukrs
        AND accountingdocument = @iv_accountingdoc
        AND fiscalyear = @iv_fiscalyear
        AND offsettingledgergllineitem = @iv_lineitem
*        AND ledgergllineitem <> @iv_lineitem
*        AND glaccount <> @iv_racct
        AND ledger = '0L'
      INTO @DATA(ls_contra).
    IF sy-subrc = 0.
      rv_contra = ls_contra-glaccount.
      RETURN.
    ELSE.
      SELECT SINGLE * FROM zfirud_cf_off
       WITH PRIVILEGED ACCESS
       WHERE bukrs = @iv_bukrs
       AND belnr = @iv_accountingdoc
       AND gjahr = @iv_fiscalyear
       AND rldnr =  '0L'
       AND racct = @iv_racct
       INTO @DATA(ls_cf_off).
      IF sy-subrc = 0.
        SELECT SINGLE * FROM zfirud_cf_off
          WITH PRIVILEGED ACCESS
          WHERE bukrs = @iv_bukrs
          AND belnr = @iv_accountingdoc
          AND gjahr = @iv_fiscalyear
          AND rldnr =  '0L'
          AND offs_item = @ls_cf_off-docln
          INTO @DATA(ls_cf_off_1).
        IF sy-subrc = 0.
          rv_contra = ls_cf_off_1-racct.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_opening_balance.
    DATA: lv_total_amount TYPE i_journalentryitem-amountincompanycodecurrency.
    DATA : lt_open_balances TYPE TABLE OF zst_open_balances.
    DATA: lt_where_clauses TYPE TABLE OF string.

    APPEND | customer = @iv_partner| TO lt_where_clauses.
    APPEND |AND postingdate < @iv_date| TO lt_where_clauses.
    APPEND |AND companycode = @iv_bukrs| TO lt_where_clauses.
    APPEND |AND ledger = '0L'| TO lt_where_clauses.
    APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses.
    APPEND |AND customer IS NOT NULL| TO lt_where_clauses.
    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses.
    APPEND |AND glaccount = @iv_racct| TO lt_where_clauses.

    IF iv_currency IS NOT INITIAL.
      APPEND |AND transactioncurrency = @iv_currency| TO lt_where_clauses.
    ENDIF.

    SELECT customer AS bp,
           companycode AS rbukrs,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS open_debit,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS open_credit,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END ) AS open_debit_tran,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END ) AS open_credit_tran,
           transactioncurrency,
           companycodecurrency,
           glaccount
      FROM i_journalentryitem
      WHERE (lt_where_clauses)
      GROUP BY customer, companycode, transactioncurrency, companycodecurrency, glaccount
      INTO CORRESPONDING FIELDS OF TABLE @lt_open_balances.

*    case thanh toán bằng usd
    DATA: lw_tienusd TYPE i_journalentryitem-amountincompanycodecurrency.
    LOOP AT lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_open1>).
      LOOP AT gt_ttusd INTO DATA(ls_ttusd) WHERE companycode = <fs_open1>-rbukrs AND glaccount = <fs_open1>-glaccount
                                             AND customer = <fs_open1>-bp AND postingdate < iv_date.
        IF <fs_open1>-transactioncurrency = 'VND'.
          IF ls_ttusd-debitcreditcode = 'S'.
            <fs_open1>-open_debit_tran = <fs_open1>-open_debit_tran - ls_ttusd-amountintransactioncurrency.
          ELSE.
            <fs_open1>-open_credit_tran = <fs_open1>-open_credit_tran - ls_ttusd-amountintransactioncurrency.
          ENDIF.
        ELSE.
          REPLACE ALL OCCURRENCES OF ',' IN ls_ttusd-reference1idbybusinesspartner WITH '.'.
          CONDENSE ls_ttusd-reference1idbybusinesspartner.
          TRY.
              IF ls_ttusd-amountintransactioncurrency < 0.
                ls_ttusd-reference1idbybusinesspartner = ls_ttusd-reference1idbybusinesspartner * -1.
              ENDIF.
              lw_tienusd = ls_ttusd-reference1idbybusinesspartner.
              IF ls_ttusd-debitcreditcode = 'S'.
                <fs_open1>-open_debit_tran = <fs_open1>-open_debit_tran + lw_tienusd.
              ELSE.
                <fs_open1>-open_credit_tran = <fs_open1>-open_credit_tran + lw_tienusd.
              ENDIF.
            CATCH cx_root INTO DATA(err).
          ENDTRY.
        ENDIF.
        CLEAR: lw_tienusd.
      ENDLOOP.
    ENDLOOP.
***Bổ sung logic lấy thêm từ chức năng đánh giá chênh lệch tỷ giá***
    FREE: lt_where_clauses.

    APPEND | account = @iv_partner| TO lt_where_clauses.
    APPEND |AND keydate < @iv_date| TO lt_where_clauses.
    APPEND |AND ccode = @iv_bukrs| TO lt_where_clauses.
    APPEND |AND account IS NOT NULL| TO lt_where_clauses.
    APPEND |AND debcred_ind IN ('S', 'H')| TO lt_where_clauses.
    APPEND |AND gl_account = @iv_racct| TO lt_where_clauses.

    IF iv_currency IS NOT INITIAL.
      APPEND |AND currency = @iv_currency| TO lt_where_clauses.
    ENDIF.

*    SELECT account AS bp,
*           ccode AS rbukrs,
*           gl_account,
*           posting_amount AS chenh_lech,
*           MAX( keydate ) AS max_keydate,
*           currency,
*           target_currency
*      FROM zui_in_faglfcv
*      WHERE (lt_where_clauses)
*      GROUP BY account, ccode, gl_account, posting_amount, currency, target_currency
*      INTO TABLE @DATA(lt_open_balances_faglfcv).

    SELECT account AS bp,
           ccode AS rbukrs,
           gl_account,
           SUM( CASE WHEN debcred_ind = 'S' THEN posting_amount ELSE 0 END ) AS open_debit_faglfcv,
           SUM( CASE WHEN debcred_ind = 'H' THEN posting_amount ELSE 0 END ) AS open_credit_faglfcv,
           currency,
           target_currency
      FROM zui_in_faglfcv
      WHERE (lt_where_clauses)
      GROUP BY account, ccode, gl_account, currency, target_currency
      INTO TABLE @DATA(lt_open_balances_faglfcv).
*********************************************************************
********************************************************************
* Thanh toán VND cho khoản gốc ngoại tệ
*    LOOP AT lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_clear>) WHERE  transactioncurrency = 'VND'.
*      CLEAR: <fs_clear>-open_debit_tran,<fs_clear>-open_credit_tran.
*    ENDLOOP.
*    IF iv_currency_para = 'VND' OR iv_currency_para = ''.
*      DATA : lw_index TYPE sy-tabix.
*      FREE: lt_where_clauses.
*      APPEND | supplier = @iv_partner| TO lt_where_clauses.
*      APPEND |AND postingdate < @iv_date| TO lt_where_clauses.
*      APPEND |AND companycode = @iv_bukrs| TO lt_where_clauses.
*      APPEND |AND ledger = '0L'| TO lt_where_clauses.
*      APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses.
*      APPEND |AND supplier IS NOT NULL| TO lt_where_clauses.
*      APPEND |AND debitcreditcode = 'H'| TO lt_where_clauses.
*      APPEND |AND glaccount = @iv_racct| TO lt_where_clauses.
**    APPEND |AND accountingdocument <> clearingaccountingdocument | TO lt_where_clauses.
*      APPEND |AND clearingaccountingdocument IS NOT NULL | TO lt_where_clauses.
*
**    IF iv_currency IS NOT INITIAL.
*      APPEND |AND transactioncurrency = 'VND'| TO lt_where_clauses.
**    ENDIF.
*      SELECT accountingdocument,
*             companycode,
*             fiscalyear,
*           CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END  AS open_debit,
*           CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END  AS open_credit,
*           CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END  AS open_debit_tran,
*           CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END  AS open_credit_tran,
*          clearingaccountingdocument,
*          transactioncurrency,
*          companycodecurrency,
*          glaccount
*     FROM i_journalentryitem
*     WHERE (lt_where_clauses)
*     INTO TABLE @DATA(lt_thanhtoannt).
*      DELETE lt_thanhtoannt WHERE clearingaccountingdocument IS INITIAL.
*      LOOP AT lt_thanhtoannt INTO DATA(ls_thanhtoannt).
*        lw_index = sy-tabix.
*        IF ls_thanhtoannt-accountingdocument = ls_thanhtoannt-clearingaccountingdocument.
*          DELETE lt_thanhtoannt INDEX sy-tabix.
*        ELSE.
*          SELECT
*          SUM( amountintransactioncurrency ) AS amountintransactioncurrency ,
*          transactioncurrency,
*          supplier,
*          glaccount
*          FROM i_journalentryitem
*          WHERE accountingdocument = @ls_thanhtoannt-clearingaccountingdocument
*          AND   companycode = @ls_thanhtoannt-companycode
*          AND fiscalyear = @ls_thanhtoannt-fiscalyear
*          AND debitcreditcode = 'S'
*          AND transactioncurrency NE 'VND'
*          AND financialaccounttype = 'D'
*          AND ledger = '0L'
*          GROUP BY transactioncurrency, supplier, glaccount
*          INTO TABLE @DATA(lt_sum).
*          READ TABLE lt_sum INTO DATA(ls_sum) INDEX 1.
*          IF sy-subrc = 0.
*            IF ls_sum-amountintransactioncurrency > 0.
*              ls_sum-amountintransactioncurrency = ls_sum-amountintransactioncurrency * -1.
*            ENDIF.
*            READ TABLE lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_open>) WITH KEY bp = ls_sum-supplier
*                                                                                   glaccount = ls_sum-glaccount
*                                                                                   transactioncurrency = 'USD'.
*            IF sy-subrc = 0.
*              <fs_open>-open_credit_tran = <fs_open>-open_credit_tran + ls_sum-amountintransactioncurrency.
*              <fs_open>-transactioncurrency = ls_sum-transactioncurrency.
*            ELSE.
*              READ TABLE lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_open_vnd>) WITH KEY bp = ls_sum-supplier
*                                                                                     glaccount = ls_sum-glaccount
*                                                                                     transactioncurrency = 'VND'.
*              IF sy-subrc = 0.
*                <fs_open_vnd>-open_credit_tran = <fs_open_vnd>-open_credit_tran + ls_sum-amountintransactioncurrency.
*                <fs_open_vnd>-transactioncurrency = ls_sum-transactioncurrency.
*                ev_thanhtoan = 'X'.
*              ENDIF.
*            ENDIF.
*            ls_thanhtoannt-open_credit_tran = ls_sum-amountintransactioncurrency.
*            ls_thanhtoannt-transactioncurrency = ls_sum-transactioncurrency.
*            MODIFY lt_thanhtoannt FROM ls_thanhtoannt INDEX lw_index.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
********************************************************************
    SORT lt_open_balances_faglfcv BY bp rbukrs.
    READ TABLE lt_open_balances_faglfcv INTO DATA(ls_open_balances_faglfcv) WITH KEY bp = iv_partner rbukrs = iv_bukrs.

    SORT lt_open_balances BY bp rbukrs.
    READ TABLE lt_open_balances INTO DATA(ls_open_balance) WITH KEY bp = iv_partner rbukrs = iv_bukrs.
    IF sy-subrc = 0.
      ev_balance = ls_open_balance-open_debit + ls_open_balance-open_credit + ls_open_balances_faglfcv-open_debit_faglfcv + ls_open_balances_faglfcv-open_credit_faglfcv.
      IF ev_balance < 0.
        ev_credit = ev_balance * -1.
        ev_debit = 0.
      ELSE.
        ev_debit = ev_balance.
        ev_credit = 0.
      ENDIF.
    ENDIF.
    ev_balance_tran = ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran.
    IF ls_open_balance-transactioncurrency NE 'VND'.
      IF ev_balance_tran < 0.
        ev_credit_tran = ev_balance_tran * -1.
        ev_debit_tran = 0.
      ELSE.
        ev_debit_tran = ev_balance_tran.
        ev_credit_tran = 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: lt_result  TYPE TABLE OF zc_accrec_detail,
          ls_result  TYPE zc_accrec_detail,
          lt_returns TYPE tt_returns.

    DATA: lt_journal_items      TYPE tt_journal_items,
          ls_journal_item       TYPE ty_journal_item,

          lt_journal_items_temp TYPE tt_journal_items,
          lt_open_balances_imp  TYPE TABLE OF zst_open_balances,
          lt_line_items         TYPE tt_line_items.

    TRY.
        " Get request details
        DATA(lo_filter) = io_request->get_filter( ).
        DATA(lt_filters) = lo_filter->get_as_ranges( ).

        " Extract filter values
        DATA(lr_bukrs) = lt_filters[ name = 'COMPANYCODE' ]-range.
        DATA(lr_racct) = lt_filters[ name = 'GLACCOUNTNUMBER' ]-range.
        DATA(lr_date_from) = lt_filters[ name = 'POSTINGDATEFROM' ]-range.
        DATA(lr_date_to) = lt_filters[ name = 'POSTINGDATETO' ]-range.
*        DATA(lv_currency) = lt_filters[ name = 'TRANSACTIONCURRENCY' ]-range[ 1 ]-low.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        " Handle error
        RETURN.
    ENDTRY.

    IF lr_date_from[ 1 ]-low > lr_date_to[ 1 ]-low.
      APPEND VALUE #(
        msgty = 'E'
        msgid = 'ZARDTLDAT'
        msgno = '001'
        msgv1 = |Ngày từ { lr_date_from[ 1 ]-low } đến { lr_date_to[ 1 ]-low } không hợp lệ|
*        msgv2 =
      ) TO lt_returns.
    ENDIF.

    READ TABLE lt_returns INDEX 1 INTO DATA(ls_return).
    IF sy-subrc = 0.
      RAISE EXCEPTION TYPE zcl_cttt_ban
        EXPORTING
          textid = VALUE scx_t100key(
                     msgid = 'ZARDTLDAT'
                     msgno = ls_return-msgno
                     attr1 = CONV string( ls_return-msgv1 )
*                     attr2 =
      ).
      RETURN.
    ENDIF.

    " Safely extract optional filters and check if provided
    DATA: lv_partner_provided      TYPE abap_bool,
          lv_profitcenter_provided TYPE abap_bool,
          lv_currency_prov         TYPE abap_bool,
          lr_partner               TYPE RANGE OF i_journalentryitem-customer,
          lr_profitcenter          TYPE RANGE OF i_journalentryitem-profitcenter,
          lr_currency              TYPE RANGE OF i_journalentryitem-transactioncurrency.

    TRY.
        DATA(lr_currency_raw) = lt_filters[ name = 'TRANSACTIONCURRENCY' ]-range.
        LOOP AT lr_currency_raw ASSIGNING FIELD-SYMBOL(<fs_currency>).
          IF <fs_currency>-low IS NOT INITIAL.
            <fs_currency>-low = |{ <fs_currency>-low ALPHA = IN WIDTH = 5 }|.
          ENDIF.
          IF <fs_currency>-high IS NOT INITIAL.
            <fs_currency>-high = |{ <fs_currency>-high ALPHA = IN WIDTH = 5 }|.
          ENDIF.
        ENDLOOP.
        MOVE-CORRESPONDING lr_currency_raw TO lr_currency.
        lv_currency_prov = abap_true.
      CATCH cx_sy_itab_line_not_found.
        CLEAR lr_currency.
    ENDTRY.


    TRY.
        DATA(lr_partner_raw) = lt_filters[ name = 'BUSINESSPARTNER' ]-range.
        LOOP AT lr_partner_raw ASSIGNING FIELD-SYMBOL(<fs_partner>).
          IF <fs_partner>-low IS NOT INITIAL.
            <fs_partner>-low = |{ <fs_partner>-low ALPHA = IN WIDTH = 10 }|.
          ENDIF.
          IF <fs_partner>-high IS NOT INITIAL.
            <fs_partner>-high = |{ <fs_partner>-high ALPHA = IN WIDTH = 10 }|.
          ENDIF.
        ENDLOOP.
        MOVE-CORRESPONDING lr_partner_raw TO lr_partner.
        lv_partner_provided = abap_true.
      CATCH cx_sy_itab_line_not_found.
        CLEAR lr_partner.
    ENDTRY.

    TRY.
        DATA(lr_profitcenter_raw) = lt_filters[ name = 'PROFITCENTER' ]-range.
        LOOP AT lr_profitcenter_raw ASSIGNING FIELD-SYMBOL(<fs_profitcenter>).
          <fs_profitcenter>-low = |{ <fs_profitcenter>-low ALPHA = IN WIDTH = 10 }|.
          IF <fs_profitcenter>-high IS NOT INITIAL.
            <fs_profitcenter>-high = |{ <fs_profitcenter>-high ALPHA = IN WIDTH = 10 }|.
          ENDIF.
        ENDLOOP.
        MOVE-CORRESPONDING lr_profitcenter_raw TO lr_profitcenter.
        lv_profitcenter_provided = abap_true.
      CATCH cx_sy_itab_line_not_found.
        CLEAR lr_profitcenter.
    ENDTRY.

    READ TABLE lt_filters INTO DATA(ls_fillter) WITH KEY name = 'CAN_TRU'.
    IF sy-subrc = 0.
      READ TABLE ls_fillter-range INTO DATA(ls_cantru) INDEX 1.
      IF ls_cantru-low = 'X' OR ls_cantru-low = 'true'.
        DATA(can_tru) = 'X'.
      ENDIF.
    ENDIF.

    DATA: lv_bukrs           TYPE bukrs,
          lv_racct           TYPE saknr,
          lv_partner         TYPE text10,
          lv_date_from       TYPE datum,
          lv_date_to         TYPE datum,
          lv_company_name    TYPE zc_accrec_detail-companyname,
          lv_company_address TYPE char256,
          lv_closing         TYPE zc_accrec_detail-closingcredit.

    " Get single values
    lv_bukrs = lr_bukrs[ 1 ]-low.

    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'ACTVT' FIELD '03'
        ID 'ZBUKRS' FIELD lv_bukrs.
    IF sy-subrc <> 0.
*    check 1 = 2.
*        lv_bukrs = 'XXXX'.
    ENDIF.

    lv_date_from = lr_date_from[ 1 ]-low.
    lv_date_to = COND #( WHEN lr_date_to[ 1 ]-low IS NOT INITIAL
                          THEN lr_date_to[ 1 ]-low
                          ELSE lv_date_from ).

    " Get company info
*    get_company_info(
*      EXPORTING
*        iv_bukrs = lv_bukrs
*      IMPORTING
*        ev_company_name = lv_company_name
*        ev_company_address = lv_company_address ).

*        " Get business partner name
*        ls_result-businesspartnername = get_business_partner_name( lv_partner ).

    DATA: lw_company          TYPE bukrs,
          ls_companycode_info TYPE zst_companycode_info.
    lw_company =  lr_bukrs[ 1 ]-low.
    CALL METHOD zcl_jp_common_core=>get_companycode_details
      EXPORTING
        i_companycode = lw_company
      IMPORTING
        o_companycode = ls_companycode_info.

    " Get company currency
*    SELECT SINGLE currency
*      FROM I_CompanyCode
*      WHERE companycode = @lv_bukrs
*      INTO @lv_currency.
    SELECT * FROM zc_ttusd
        WHERE companycode = @lv_bukrs
        AND  glaccount IN @lr_racct
        AND glaccount NOT LIKE '128%'
        AND postingdate <= @lv_date_to
        AND financialaccounttype = 'D'
         AND customer IN @lr_partner
         AND profitcenter IN @lr_profitcenter
         AND ( accountingdocumenttype = 'DZ' OR accountingdocumenttype = 'DJ' )
         INTO TABLE @gt_ttusd.
    SORT gt_ttusd BY companycode fiscalyear accountingdocument accountingdocumentitem.


    DATA: lt_where_clauses TYPE TABLE OF string.

    APPEND | companycode = '{ lv_bukrs }'| TO lt_where_clauses.
    APPEND |and glaccount IN @lr_racct| TO lt_where_clauses.
    APPEND |and glaccount NOT LIKE '128%'| TO lt_where_clauses.
    APPEND |and postingdate BETWEEN '{ lv_date_from }' AND '{ lv_date_to }'| TO lt_where_clauses.
    APPEND |and ledger = '0L'| TO lt_where_clauses.
    APPEND |and financialaccounttype = 'D'| TO lt_where_clauses.
    APPEND |and AccountingDocument NOT LIKE 'B%'| TO lt_where_clauses.

    IF lv_partner_provided = abap_true.
      APPEND |and customer IN @lr_partner| TO lt_where_clauses.
    ENDIF.

    IF lv_profitcenter_provided = abap_true.
      APPEND |and ProfitCenter IN @lr_profitcenter| TO lt_where_clauses.
    ENDIF.

    READ TABLE lr_currency INTO DATA(ls_curr) INDEX 1.

    IF lv_currency_prov = abap_true AND ls_curr-low NE 'VND'.
      APPEND |and TRANSACTIONCURRENCY in @lr_currency| TO lt_where_clauses.
    ENDIF.


    SELECT companycode,
           fiscalyear,
           accountingdocument,
           isreversed,
           reversalreferencedocument,
           reversalreferencedocumentcntxt,
           ledgergllineitem,
           accountingdocumentitem,
           postingdate,
           documentdate,
           glaccount,
           customer,
           amountincompanycodecurrency,
           amountintransactioncurrency,
           companycodecurrency,
           transactioncurrency,
           debitcreditcode,
           accountingdocumenttype,
           documentitemtext,
           profitcenter,
           yy1_text2_cob AS addtext2,
           financialaccounttype,
           clearingaccountingdocument,
           offsettingaccounttype,
           subledgeracctlineitemtype
      FROM i_journalentryitem
      WHERE (lt_where_clauses)
      INTO CORRESPONDING FIELDS OF TABLE @lt_journal_items.
    SORT lt_journal_items BY companycode accountingdocument fiscalyear ASCENDING.

    IF sy-subrc EQ 0.
      SELECT companycode,
             fiscalyear,
             accountingdocument,
             isreversal,
             isreversed,
             reversedocument,
             originalreferencedocument,
             postingdate
          FROM i_journalentry
          FOR ALL ENTRIES IN @lt_journal_items
          WHERE companycode = @lt_journal_items-companycode
          AND accountingdocument = @lt_journal_items-accountingdocument
          AND fiscalyear = @lt_journal_items-fiscalyear
*        AND postingdate BETWEEN @lv_date_from AND @lv_date_to
          INTO TABLE @DATA(lt_journal_headers).
      SORT lt_journal_headers BY companycode accountingdocument fiscalyear ASCENDING.
    ENDIF.

*    loaij ctu can tru
    IF can_tru = 'X'.
      LOOP AT lt_journal_items INTO DATA(ls_cantru_item).
        ls_cantru_item-amountincompanycodecurrency = ls_cantru_item-amountincompanycodecurrency * -1.
        ls_cantru_item-amountintransactioncurrency = ls_cantru_item-amountintransactioncurrency * -1.
        LOOP AT lt_journal_items INTO DATA(ls_del)
                              WHERE glaccount = ls_cantru_item-glaccount
                               AND accountingdocument = ls_cantru_item-accountingdocument
                               AND financialaccounttype = ls_cantru_item-financialaccounttype
                               AND customer = ls_cantru_item-customer
                               AND amountincompanycodecurrency = ls_cantru_item-amountincompanycodecurrency
                               AND amountintransactioncurrency = ls_cantru_item-amountintransactioncurrency.

          DELETE lt_journal_items WHERE accountingdocument = ls_cantru_item-accountingdocument AND fiscalyear = ls_cantru_item-fiscalyear
                                AND  ledgergllineitem = ls_cantru_item-ledgergllineitem AND companycode = ls_cantru_item-companycode.
          DELETE lt_journal_items WHERE accountingdocument = ls_del-accountingdocument AND fiscalyear = ls_del-fiscalyear
                                AND  ledgergllineitem = ls_del-ledgergllineitem  AND companycode = ls_del-companycode.
          EXIT.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    " loại bỏ cặp chứng từ hủy cùng kỳ.
    DATA: lt_huy       LIKE lt_journal_items,
          ls_huy       LIKE LINE OF lt_huy,
          lv_index_huy TYPE sy-tabix,

          lv_length    TYPE n LENGTH 3,
          lv_docnum    TYPE i_journalentryitem-accountingdocument,
          lv_year      TYPE i_journalentryitem-fiscalyear.

    lt_huy = lt_journal_items.


    SORT lt_huy BY companycode accountingdocument fiscalyear ASCENDING.

    LOOP AT lt_huy INTO DATA(ls_check_item) WHERE isreversed IS NOT INITIAL.
      lv_index_huy = sy-tabix.

      READ TABLE lt_journal_headers INTO DATA(ls_check_header) WITH KEY companycode = ls_check_item-companycode
                                                                        accountingdocument = ls_check_item-accountingdocument
                                                                        fiscalyear = ls_check_item-fiscalyear BINARY SEARCH.

      IF sy-subrc = 0.
        lv_length = strlen( ls_check_header-originalreferencedocument ) - 4.
        lv_docnum = ls_check_header-originalreferencedocument(lv_length).
        lv_year = ls_check_header-originalreferencedocument+lv_length.

        IF lv_docnum IS NOT INITIAL.
          DELETE lt_journal_items WHERE reversalreferencedocument = lv_docnum AND fiscalyear = lv_year.
          IF sy-subrc = 0.
            DELETE lt_journal_items WHERE accountingdocument = ls_check_item-accountingdocument AND fiscalyear = lv_year.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR: ls_check_item, ls_check_header, lv_length, lv_docnum, lv_year.
    ENDLOOP.

*    bổ xung logic chứng từ 6112
    DATA(lt_temp) = lt_journal_items[].
    SORT lt_temp BY fiscalyear accountingdocument companycode.
    DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING fiscalyear accountingdocument companycode.
    SELECT DISTINCT fiscalyear, accountingdocument, companycode
        FROM i_journalentryitem
        FOR ALL ENTRIES IN @lt_temp
        WHERE fiscalyear = @lt_temp-fiscalyear
        AND accountingdocument = @lt_temp-accountingdocument
        AND companycode = @lt_temp-companycode
        AND ledger = '0L'
        AND subledgeracctlineitemtype = '06112'
        INTO TABLE @DATA(lt_6112).
    IF sy-subrc = 0.
      SELECT companycode,
           fiscalyear,
           accountingdocument,
           ledgergllineitem,
           accountingdocumentitem,
           amountincompanycodecurrency,
           amountintransactioncurrency,
           offsettingaccounttype,
           subledgeracctlineitemtype,
           glaccount
        FROM i_journalentryitem
        FOR ALL ENTRIES IN @lt_6112
        WHERE fiscalyear = @lt_6112-fiscalyear
        AND ledger = '0L'
        AND accountingdocument = @lt_6112-accountingdocument
        AND companycode = @lt_6112-companycode
        INTO TABLE @DATA(lt_6112_item).

      DATA: lw_lineitem TYPE n  LENGTH 6.
      SORT lt_6112_item BY fiscalyear accountingdocument companycode ledgergllineitem offsettingaccounttype.
      SORT lt_journal_items BY amountincompanycodecurrency.
      LOOP AT lt_6112_item INTO DATA(ls_6112) WHERE  offsettingaccounttype = 'S' AND glaccount IN lr_racct.
        IF ls_6112-ledgergllineitem MOD 2 = 0.
          lw_lineitem = ls_6112-ledgergllineitem - 1.
        ELSE.
          lw_lineitem = ls_6112-ledgergllineitem + 1.
        ENDIF.
        READ TABLE lt_6112_item INTO DATA(ls_6112_item) WITH KEY fiscalyear = ls_6112-fiscalyear
                                                                 accountingdocument = ls_6112-accountingdocument
                                                                 companycode = ls_6112-companycode
                                                                 ledgergllineitem = lw_lineitem BINARY SEARCH.
        IF sy-subrc = 0.
          DATA lw_chenhlech TYPE zde_dec23_2.
          lw_chenhlech = ls_6112_item-amountintransactioncurrency + ls_6112-amountintransactioncurrency.
          CHECK lw_chenhlech <> 0.
          DATA: lw_count TYPE char03.
          CLEAR: lw_count.
          LOOP AT lt_journal_items ASSIGNING FIELD-SYMBOL(<fs_count>) WHERE fiscalyear = ls_6112_item-fiscalyear
                                                                      AND accountingdocument = ls_6112_item-accountingdocument
                                                                      AND companycode = ls_6112_item-companycode
                                                                      AND accountingdocumentitem = ls_6112-accountingdocumentitem.
            lw_count = lw_count + 1.
            IF lw_count > 1.
              EXIT.
            ENDIF.
          ENDLOOP.
          CHECK lw_count > 1.


          LOOP AT lt_journal_items ASSIGNING FIELD-SYMBOL(<fs_6112>) WHERE fiscalyear = ls_6112_item-fiscalyear
                                                                      AND accountingdocument = ls_6112_item-accountingdocument
                                                                      AND companycode = ls_6112_item-companycode
                                                                      AND accountingdocumentitem = ls_6112-accountingdocumentitem
                                                                      AND offsettingaccounttype <> ls_6112-offsettingaccounttype.
            <fs_6112>-amountintransactioncurrency = <fs_6112>-amountintransactioncurrency + lw_chenhlech.
            EXIT.
          ENDLOOP.

          CHECK sy-subrc = 0.

          READ TABLE lt_journal_items ASSIGNING <fs_6112> WITH KEY fiscalyear = ls_6112-fiscalyear
                                                                 accountingdocument = ls_6112-accountingdocument
                                                                 companycode = ls_6112-companycode
                                                                 ledgergllineitem = ls_6112-ledgergllineitem.
          IF sy-subrc = 0.
            <fs_6112>-amountintransactioncurrency = ls_6112_item-amountintransactioncurrency * -1.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    SORT lt_journal_items BY companycode fiscalyear accountingdocument accountingdocumentitem.

    DATA: lw_tienusd TYPE i_operationalacctgdocitem-amountintransactioncurrency.
    LOOP AT lt_journal_items ASSIGNING FIELD-SYMBOL(<fs_acdoca>) WHERE financialaccounttype = 'D' AND transactioncurrency = 'VND' AND ( accountingdocumenttype = 'DZ' OR accountingdocumenttype = 'DJ' ).
      READ TABLE gt_ttusd INTO DATA(ls_tyle) WITH KEY companycode = <fs_acdoca>-companycode
                                                fiscalyear = <fs_acdoca>-fiscalyear
                                                accountingdocument = <fs_acdoca>-accountingdocument
                                                accountingdocumentitem = <fs_acdoca>-accountingdocumentitem
                                                BINARY SEARCH.
      IF sy-subrc = 0.
        IF sy-subrc = 0.
          REPLACE ALL OCCURRENCES OF ',' IN ls_tyle-reference1idbybusinesspartner WITH '.'.
          CONDENSE ls_tyle-reference1idbybusinesspartner.
          TRY.
              IF ls_tyle-amountintransactioncurrency < 0.
                ls_tyle-reference1idbybusinesspartner = ls_tyle-reference1idbybusinesspartner * -1.
              ENDIF.
              <fs_acdoca>-amountintransactioncurrency = <fs_acdoca>-amountintransactioncurrency * ls_tyle-reference1idbybusinesspartner / ls_tyle-amountintransactioncurrency.
              <fs_acdoca>-transactioncurrency = 'USD'.
              lw_tienusd = lw_tienusd + <fs_acdoca>-amountintransactioncurrency.

              AT END OF accountingdocumentitem.
                <fs_acdoca>-amountintransactioncurrency = ls_tyle-reference1idbybusinesspartner - lw_tienusd + <fs_acdoca>-amountintransactioncurrency.
                CLEAR: lw_tienusd.
              ENDAT.
            CATCH cx_root INTO DATA(err).
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDLOOP.


    SORT lt_journal_items BY companycode glaccount customer companycodecurrency transactioncurrency.

***bổ sung logic lấy thêm từ chức năng đánh giá chênh lệch tỷ giá***
    FREE: lt_where_clauses.

    APPEND | ccode = '{ lv_bukrs }'| TO lt_where_clauses.
    APPEND |AND gl_account IN @lr_racct| TO lt_where_clauses.
    APPEND |AND gl_account NOT LIKE '128%'| TO lt_where_clauses.
*    APPEND |AND keydate < '{ lv_date_to }'| TO lt_where_clauses.
    APPEND |AND keydate BETWEEN '{ lv_date_from }' AND '{ lv_date_to }'| TO lt_where_clauses.

    IF lv_partner_provided = abap_true.
      APPEND |AND account IN @lr_partner| TO lt_where_clauses.
    ENDIF.

    IF lv_currency_prov = abap_true AND ls_curr-low NE 'VND'.
      APPEND |AND currency in @lr_currency| TO lt_where_clauses.
    ENDIF.

*    SELECT
*          ccode,
*          account,
*          gl_account,
*          doc_number,
*          MAX( keydate ) AS max_keydate,
*          debcred_ind,
*          posting_amount,
*          currency,
*          target_currency
*        FROM zui_in_faglfcv
*        WHERE (lt_where_clauses)
*        GROUP BY ccode, account, gl_account, doc_number, debcred_ind, posting_amount, currency, target_currency
*        INTO TABLE @DATA(lt_in_faglfcv).

    SELECT
          ccode,
          account,
          gl_account,
          doc_number,
          keydate,
          SUM( CASE WHEN debcred_ind = 'S' THEN posting_amount ELSE 0 END ) AS debit_faglfcv,
          SUM( CASE WHEN debcred_ind = 'H' THEN posting_amount ELSE 0 END ) AS credit_faglfcv,
          currency,
          target_currency
        FROM zui_in_faglfcv
        WHERE (lt_where_clauses)
        GROUP BY ccode, account, gl_account, doc_number, keydate, currency, target_currency
        INTO TABLE @DATA(lt_in_faglfcv).
    SORT lt_in_faglfcv BY ccode account gl_account currency target_currency ASCENDING.
********************************************************************

    DATA: lt_each_page           TYPE tt_journal_items,
          lt_each_page_faglfcv   TYPE tt_in_faglfcv,
          lv_last_creadit_amount TYPE wrbtr,
          lv_last_debit_amount   TYPE wrbtr.

    DATA(lo_common_app) = zcl_jp_common_core=>get_instance( ).


    " Process period data
    LOOP AT lt_journal_items INTO DATA(lg_journal_items)
    GROUP BY (
        companycode = lg_journal_items-companycode
        glaccount = lg_journal_items-glaccount
        customer =  lg_journal_items-customer
        companycodecurrency = lg_journal_items-companycodecurrency
        transactioncurrency = lg_journal_items-transactioncurrency
    )
    ASSIGNING FIELD-SYMBOL(<group>).
      " For each group, process the journal items
      LOOP AT GROUP <group> INTO DATA(ls_item).
        APPEND ls_item TO lt_each_page.
      ENDLOOP.

      LOOP AT lt_in_faglfcv INTO DATA(ls_in_faglfcv) WHERE ccode = <group>-companycode
                                                     AND account = <group>-customer
                                                     AND gl_account = <group>-glaccount
                                                     AND currency = <group>-transactioncurrency
                                                     AND target_currency = <group>-companycodecurrency.
        APPEND ls_in_faglfcv TO lt_each_page_faglfcv.
      ENDLOOP.

      READ TABLE lr_currency INTO DATA(ls_currency) INDEX 1.

      ls_result-companyname = ls_companycode_info-companycodename.
      ls_result-companyaddress = ls_companycode_info-companycodeaddr.

      ls_result-transactioncurrency = ls_item-transactioncurrency.
      ls_result-companycodecurrency = ls_item-companycodecurrency.
      lv_racct = <group>-glaccount.
      lv_partner = <group>-customer.

      " Get opening balance
      get_opening_balance(
        EXPORTING
          iv_bukrs         = lv_bukrs
          iv_racct         = lv_racct
          iv_partner       = lv_partner
          iv_date          = lv_date_from
          iv_currency      = ls_result-transactioncurrency " ls_currency-low
          iv_currency_para = ls_currency-low
        IMPORTING
          ev_debit         = ls_result-openingdebitbalance
          ev_credit        = ls_result-openingcreditbalance
*         ev_balance       = ls_result-openingbalance
          ev_debit_tran    = ls_result-openingdebitbalancetran
          ev_credit_tran   = ls_result-openingcreditbalancetran
*         ev_balance_tran  = ls_result-OpeningBalanceTran
          tt_open_balances = lt_open_balances_imp
          ev_thanhtoan     = ls_result-thanhtoannt  "d
      ).

      process_period_data(
        EXPORTING
          it_journal_items     = lt_each_page
          it_open_balances     = lt_open_balances_imp
          it_in_faglfcv        = lt_each_page_faglfcv
          iv_bukrs             = lv_bukrs
          iv_racct             = lv_racct
          iv_partner           = lv_partner
          iv_date_from         = lv_date_from
          iv_date_to           = lv_date_to
          iv_currency          = ls_result-transactioncurrency
        IMPORTING
          et_line_items        = lt_line_items
          ev_debit_total       = ls_result-debitamountduringperiod
          ev_credit_total      = ls_result-creditamountduringperiod
          ev_debit_total_tran  = ls_result-debitamountduringperiodtran
          ev_credit_total_tran = ls_result-creditamountduringperiodtran
      ).

      " Nếu tran curency = 'VND', bỏ tran amount chỉ lấy company amount.
      LOOP AT lt_line_items ASSIGNING FIELD-SYMBOL(<fs_line_items>).
        IF ( ( ls_result-transactioncurrency = 'VND' AND <fs_line_items>-thanhtoannt NE 'X' ) OR ls_curr-low = 'VND' ).
          CLEAR:
          <fs_line_items>-debit_amount_tran,
          <fs_line_items>-credit_amount_tran,
          <fs_line_items>-balance_tran,
          <fs_line_items>-closingcredit_tran,
          <fs_line_items>-closingdebit_tran.
        ENDIF.
        IF ls_result-transactioncurrency = 'VND' AND <fs_line_items>-thanhtoannt = 'X'.
          ls_result-thanhtoannt = 'X'.
        ENDIF.
      ENDLOOP.

      " Convert line items to JSON
      ls_result-lineitemsjson = convert_line_items_to_json( lt_line_items ).

      " Calculate closing balance based on account nature
      DATA(lv_account_nature) = determine_account_nature( lv_racct ).

      lv_closing = ls_result-openingdebitbalance - ls_result-openingcreditbalance +
          ls_result-debitamountduringperiod - ls_result-creditamountduringperiod.
      IF lv_closing < 0.
        ls_result-closingcredit = lv_closing * -1.
      ELSE.
        ls_result-closingdebit = lv_closing.
      ENDIF.
      CLEAR lv_closing.
      " Calculate closing balance in transaction currency
      lv_closing = ls_result-openingdebitbalancetran - ls_result-openingcreditbalancetran +
          ls_result-debitamountduringperiodtran - ls_result-creditamountduringperiodtran.
      IF lv_closing < 0.
        ls_result-closingcredittran = lv_closing * -1.
      ELSE.
        ls_result-closingdebittran = lv_closing.
      ENDIF.

      " Set key fields
      ls_result-companycode = lv_bukrs.
      ls_result-glaccountnumber = lv_racct.
      ls_result-businesspartner = lv_partner.
      ls_result-postingdatefrom = lv_date_from.
      ls_result-postingdateto = lv_date_to.

      " Get business partner name
*      ls_result-businesspartnername = get_business_partner_name( lv_partner ).

      DATA: ls_businesspartner_details TYPE zst_document_info.

      ls_businesspartner_details-customer = lv_partner.
      ls_businesspartner_details-companycode = lv_bukrs.

      lo_common_app->get_businesspartner_details(
        EXPORTING
          i_document  = ls_businesspartner_details
        IMPORTING
          o_bpdetails = DATA(ls_bp_details)
      ).

      ls_result-businesspartnername = ls_bp_details-bpname.

      APPEND ls_result TO lt_result.
      CLEAR: lt_each_page, lt_each_page_faglfcv, lt_line_items, ls_result, lv_closing.
    ENDLOOP.

    " Thêm để lấy số không có phát sinh
    DATA: lt_where_clauses_open TYPE TABLE OF string.

    APPEND | customer IN @lr_partner| TO lt_where_clauses_open.
    APPEND |AND postingdate < '{ lv_date_from }'| TO lt_where_clauses_open.
    APPEND |AND companycode IN @lr_bukrs| TO lt_where_clauses_open.
    APPEND |AND ledger = '0L'| TO lt_where_clauses_open.
    APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses_open.
    APPEND |AND customer IS NOT NULL| TO lt_where_clauses_open.
    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses_open.
    APPEND |AND glaccount IN @lr_racct| TO lt_where_clauses_open.
    APPEND |AND glaccount NOT LIKE '128%'| TO lt_where_clauses_open.

    IF lr_currency IS NOT INITIAL AND ls_curr-low NE 'VND'.
      APPEND |AND transactioncurrency IN @lr_currency| TO lt_where_clauses_open.
    ENDIF.
    DATA  lt_open_balances TYPE TABLE OF zst_open_balances_sum.
    " 3. Fetch open and end balances in bulk
    SELECT customer AS bp,
           companycode AS rbukrs,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS open_debit,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS open_credit,
           SUM( CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END ) AS open_debit_tran,
           SUM( CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END ) AS open_credit_tran,
           companycodecurrency,
           transactioncurrency,
           glaccount
           FROM i_journalentryitem
           WHERE (lt_where_clauses_open)
           GROUP BY customer, companycode,  transactioncurrency, companycodecurrency, glaccount
           INTO CORRESPONDING FIELDS OF TABLE @lt_open_balances.

*    case thanh toán bằng usd
    LOOP AT lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_open1>).
      LOOP AT gt_ttusd INTO DATA(ls_ttusd) WHERE companycode = <fs_open1>-rbukrs AND glaccount = <fs_open1>-glaccount
                                             AND customer = <fs_open1>-bp AND postingdate < lv_date_from.
        IF <fs_open1>-transactioncurrency = 'VND'.
          IF ls_ttusd-debitcreditcode = 'S'.
            <fs_open1>-open_debit_tran = <fs_open1>-open_debit_tran - ls_ttusd-amountintransactioncurrency.
          ELSE.
            <fs_open1>-open_credit_tran = <fs_open1>-open_credit_tran - ls_ttusd-amountintransactioncurrency.
          ENDIF.
        ELSE.
          REPLACE ALL OCCURRENCES OF ',' IN ls_ttusd-reference1idbybusinesspartner WITH '.'.
          CONDENSE ls_ttusd-reference1idbybusinesspartner.
          TRY.
              IF ls_ttusd-amountintransactioncurrency < 0.
                ls_ttusd-reference1idbybusinesspartner = ls_ttusd-reference1idbybusinesspartner * -1.
              ENDIF.
              lw_tienusd = ls_ttusd-reference1idbybusinesspartner.
              IF ls_ttusd-debitcreditcode = 'S'.
                <fs_open1>-open_debit_tran = <fs_open1>-open_debit_tran + lw_tienusd.
              ELSE.
                <fs_open1>-open_credit_tran = <fs_open1>-open_credit_tran + lw_tienusd.
              ENDIF.
            CATCH cx_root INTO err.
          ENDTRY.
        ENDIF.
        CLEAR: lw_tienusd.
      ENDLOOP.
    ENDLOOP.
********************************************************************
* Thanh toán VND cho khoản gốc ngoại tệ
*    LOOP AT lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_clear>) WHERE  transactioncurrency = 'VND'.
*      CLEAR: <fs_clear>-open_debit_tran,<fs_clear>-open_credit_tran.
*    ENDLOOP.
*    IF ls_currency-low = 'VND' OR ls_currency-low = ''.
*      DATA : lw_index TYPE sy-tabix.
*      FREE: lt_where_clauses.
**      APPEND | supplier = @iv_partner| TO lt_where_clauses.
**      APPEND |AND postingdate < @iv_date| TO lt_where_clauses.
**      APPEND |AND companycode = @iv_bukrs| TO lt_where_clauses.
**      APPEND |AND ledger = '0L'| TO lt_where_clauses.
**      APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses.
**      APPEND |AND supplier IS NOT NULL| TO lt_where_clauses.
**      APPEND |AND debitcreditcode = 'H'| TO lt_where_clauses.
**      APPEND |AND glaccount = @iv_racct| TO lt_where_clauses.
**    APPEND |AND accountingdocument <> clearingaccountingdocument | TO lt_where_clauses.
*
*      APPEND | customer IN @lr_partner| TO lt_where_clauses.
*      APPEND |AND postingdate < '{ lv_date_from }'| TO lt_where_clauses.
*      APPEND |AND companycode IN @lr_bukrs| TO lt_where_clauses.
*      APPEND |AND ledger = '0L'| TO lt_where_clauses.
*      APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses.
*      APPEND |AND customer IS NOT NULL| TO lt_where_clauses.
*      APPEND |AND debitcreditcode = 'S'| TO lt_where_clauses.
*      APPEND |AND glaccount IN @lr_racct| TO lt_where_clauses.
*      APPEND |AND glaccount NOT LIKE '128%'| TO lt_where_clauses.
*      APPEND |AND clearingaccountingdocument IS NOT NULL | TO lt_where_clauses.
*
**    IF iv_currency IS NOT INITIAL.
*      APPEND |AND transactioncurrency = 'VND'| TO lt_where_clauses.
**    ENDIF.
*      SELECT accountingdocument,
*             companycode,
*             fiscalyear,
*           CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END  AS open_debit,
*           CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END  AS open_credit,
*           CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END  AS open_debit_tran,
*           CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END  AS open_credit_tran,
*          clearingaccountingdocument,
*          transactioncurrency,
*          companycodecurrency,
*          glaccount
*     FROM i_journalentryitem
*     WHERE (lt_where_clauses)
*     INTO TABLE @DATA(lt_thanhtoannt).
*      DELETE lt_thanhtoannt WHERE clearingaccountingdocument IS INITIAL.
*      LOOP AT lt_thanhtoannt INTO DATA(ls_thanhtoannt).
*        lw_index = sy-tabix.
*        IF ls_thanhtoannt-accountingdocument = ls_thanhtoannt-clearingaccountingdocument.
*          DELETE lt_thanhtoannt INDEX sy-tabix.
*        ELSE.
*          SELECT
*          SUM( amountintransactioncurrency ) AS amountintransactioncurrency ,
*          transactioncurrency,
*          supplier,
*          glaccount
*          FROM i_journalentryitem
*          WHERE accountingdocument = @ls_thanhtoannt-clearingaccountingdocument
*          AND   companycode = @ls_thanhtoannt-companycode
*          AND fiscalyear = @ls_thanhtoannt-fiscalyear
*          AND debitcreditcode = 'S'
*          AND transactioncurrency NE 'VND'
*          AND financialaccounttype = 'D'
*          AND ledger = '0L'
*          GROUP BY transactioncurrency, supplier, glaccount
*          INTO TABLE @DATA(lt_sum).
*          READ TABLE lt_sum INTO DATA(ls_sum) INDEX 1.
*          IF sy-subrc = 0.
*            IF ls_sum-amountintransactioncurrency > 0.
*              ls_sum-amountintransactioncurrency = ls_sum-amountintransactioncurrency * -1.
*            ENDIF.
*            READ TABLE lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_open>) WITH KEY bp = ls_sum-supplier
*                                                                                   glaccount = ls_sum-glaccount
*                                                                                   transactioncurrency = 'USD'.
*            IF sy-subrc = 0.
*              <fs_open>-open_credit_tran = <fs_open>-open_credit_tran + ls_sum-amountintransactioncurrency.
*              <fs_open>-transactioncurrency = ls_sum-transactioncurrency.
*            ELSE.
*              READ TABLE lt_open_balances ASSIGNING FIELD-SYMBOL(<fs_open_vnd>) WITH KEY bp = ls_sum-supplier
*                                                                                     glaccount = ls_sum-glaccount
*                                                                                     transactioncurrency = 'VND'.
*              IF sy-subrc = 0.
*                <fs_open_vnd>-open_credit_tran = <fs_open_vnd>-open_credit_tran + ls_sum-amountintransactioncurrency.
*                <fs_open_vnd>-transactioncurrency = ls_sum-transactioncurrency.
*                <fs_open_vnd>-thanhtoannt = 'X'.
*              ENDIF.
*            ENDIF.
*            ls_thanhtoannt-open_credit_tran = ls_sum-amountintransactioncurrency.
*            ls_thanhtoannt-transactioncurrency = ls_sum-transactioncurrency.
*            MODIFY lt_thanhtoannt FROM ls_thanhtoannt INDEX lw_index.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
********************************************************************



***bổ sung logic lấy thêm từ chức năng đánh giá chênh lệch tỷ giá***
    " lấy sinh dư đầu kỳ
    FREE: lt_where_clauses_open.

    APPEND | account IN @lr_partner| TO lt_where_clauses_open.
    APPEND |AND keydate < '{ lv_date_from }'| TO lt_where_clauses_open.
    APPEND |AND ccode IN @lr_bukrs| TO lt_where_clauses_open.
    APPEND |AND account IS NOT NULL| TO lt_where_clauses_open.
    APPEND |AND debcred_ind IN ('S', 'H')| TO lt_where_clauses_open.
    APPEND |AND gl_account IN @lr_racct| TO lt_where_clauses_open.
    APPEND |AND gl_account NOT LIKE '128%'| TO lt_where_clauses_open.

    IF lr_currency IS NOT INITIAL AND ls_curr-low NE 'VND'.
      APPEND |AND currency IN @lr_currency| TO lt_where_clauses_open.
    ENDIF.

    SELECT account AS bp,
           ccode AS rbukrs,
           SUM( CASE WHEN debcred_ind = 'S' THEN posting_amount ELSE 0 END ) AS open_debit_faglfcv,
           SUM( CASE WHEN debcred_ind = 'H' THEN posting_amount ELSE 0 END ) AS open_credit_faglfcv,
           currency,
           target_currency,
           gl_account
      FROM zui_in_faglfcv
      WHERE (lt_where_clauses_open)
      GROUP BY account, ccode, currency, target_currency, gl_account
      INTO TABLE @DATA(lt_open_balances_faglfcv).
    SORT lt_open_balances_faglfcv BY rbukrs bp gl_account currency target_currency ASCENDING.
********************************************************************

    SORT lt_result BY companycode businesspartner glaccountnumber transactioncurrency companycodecurrency ASCENDING.

    LOOP AT lt_open_balances  INTO DATA(ls_ko_phat_sinh).
      READ TABLE lt_result WITH KEY companycode = ls_ko_phat_sinh-rbukrs
                                    businesspartner = ls_ko_phat_sinh-bp
                                    glaccountnumber = ls_ko_phat_sinh-glaccount
                                    transactioncurrency = ls_ko_phat_sinh-transactioncurrency
                                    companycodecurrency = ls_ko_phat_sinh-companycodecurrency
                                    TRANSPORTING NO FIELDS.

      IF sy-subrc <> 0.
        ls_result-transactioncurrency = ls_ko_phat_sinh-transactioncurrency.
        ls_result-companycodecurrency = ls_ko_phat_sinh-companycodecurrency.
        ls_result-thanhtoannt = ls_ko_phat_sinh-thanhtoannt.
        ls_result-companycode = ls_ko_phat_sinh-rbukrs.
        ls_result-companyname = ls_companycode_info-companycodename.
        ls_result-companyaddress = ls_companycode_info-companycodeaddr.
        ls_result-businesspartner = ls_ko_phat_sinh-bp.

        CLEAR: ls_businesspartner_details, ls_bp_details.

        ls_businesspartner_details-companycode = ls_ko_phat_sinh-rbukrs.
        ls_businesspartner_details-customer = ls_ko_phat_sinh-bp.

        lo_common_app->get_businesspartner_details(
          EXPORTING
            i_document  = ls_businesspartner_details
          IMPORTING
            o_bpdetails = ls_bp_details
        ).

*        ls_result-businesspartnername = get_business_partner_name( ls_ko_phat_sinh-bp ).
        ls_result-businesspartnername = ls_bp_details-bpname.
        ls_result-glaccountnumber = ls_ko_phat_sinh-glaccount.

        DATA: ls_line_item  LIKE LINE OF lt_line_items,
              lv_chenh_lech TYPE zui_in_faglfcv-posting_amount.

        READ TABLE lt_open_balances_faglfcv INTO DATA(ls_open_balances_faglfcv) WITH KEY rbukrs = ls_ko_phat_sinh-rbukrs
                                                                                         bp = ls_ko_phat_sinh-bp
                                                                                         gl_account = ls_ko_phat_sinh-glaccount
                                                                                         currency = ls_ko_phat_sinh-transactioncurrency
                                                                                         target_currency = ls_ko_phat_sinh-companycodecurrency
                                                                                         BINARY SEARCH.

        CLEAR: lv_chenh_lech.
        lv_chenh_lech = ls_open_balances_faglfcv-open_debit_faglfcv + ls_open_balances_faglfcv-open_credit_faglfcv.

        IF ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech > 0.
          ls_result-openingdebitbalance = ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech.
          ls_result-openingcreditbalance = 0.
        ELSEIF ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech < 0.
          ls_result-openingdebitbalance = 0.
          ls_result-openingcreditbalance = abs( ls_ko_phat_sinh-open_debit + ls_ko_phat_sinh-open_credit + lv_chenh_lech ).
        ENDIF.

        ls_result-openingdebitbalancetran = ls_ko_phat_sinh-open_debit_tran.
        ls_result-openingcreditbalancetran = ls_ko_phat_sinh-open_credit_tran * -1.

        ls_result-closingdebit = ls_result-openingdebitbalance.
        ls_result-closingdebittran = ls_result-openingdebitbalancetran.
        ls_result-closingcredit = ls_result-openingcreditbalance.
        ls_result-closingcredittran = ls_result-openingcreditbalancetran.

*        READ TABLE lt_in_faglfcv INTO DATA(ls_ko_phat_sinh_faglfcv) WITH KEY ccode = ls_ko_phat_sinh-rbukrs
*                                                                             account = ls_ko_phat_sinh-bp
*                                                                             gl_account = ls_ko_phat_sinh-GLAccount
*                                                                             currency = ls_ko_phat_sinh-TransactionCurrency
*                                                                             target_currency = ls_ko_phat_sinh-CompanyCodeCurrency
*                                                                             BINARY SEARCH.

        LOOP AT lt_in_faglfcv INTO DATA(ls_ko_phat_sinh_faglfcv) WHERE ccode = ls_ko_phat_sinh-rbukrs
                                                                   AND account = ls_ko_phat_sinh-bp
                                                                   AND gl_account = ls_ko_phat_sinh-glaccount
                                                                   AND currency = ls_ko_phat_sinh-transactioncurrency
                                                                   AND target_currency = ls_ko_phat_sinh-companycodecurrency.

          ls_line_item-posting_date = ls_ko_phat_sinh_faglfcv-keydate.
*          ls_line_item-document_number = ls_ko_phat_sinh_faglfcv-doc_number.
          ls_line_item-document_number = ||.
          ls_line_item-document_date = ls_ko_phat_sinh_faglfcv-keydate.
          ls_line_item-transactioncurrency = ls_ko_phat_sinh_faglfcv-currency.
          ls_line_item-companycodecurrency = ls_ko_phat_sinh_faglfcv-target_currency.
          ls_line_item-item_text = |Đánh giá chênh lệch tỷ giá|.

          CLEAR: lv_chenh_lech.
          lv_chenh_lech = ls_ko_phat_sinh_faglfcv-debit_faglfcv + ls_ko_phat_sinh_faglfcv-credit_faglfcv.

          IF lv_chenh_lech > 0.
            ls_line_item-contra_account = '5151001010'.

            ls_line_item-debit_amount = lv_chenh_lech.
            ls_result-debitamountduringperiod = ls_result-debitamountduringperiod + ls_line_item-debit_amount.
          ELSE.
            ls_line_item-contra_account = '6351001000'.

            ls_line_item-credit_amount = lv_chenh_lech * -1.
            ls_result-creditamountduringperiod = ls_result-creditamountduringperiod + ls_line_item-credit_amount.
          ENDIF.

          IF ls_ko_phat_sinh_faglfcv-keydate+6(2) = 1.
            IF lv_chenh_lech < 0.
              ls_line_item-contra_account = '5151001010'.
            ELSE.
              ls_line_item-contra_account = '6351001000'.
            ENDIF.
          ENDIF.

          IF ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech > 0.
            ls_result-closingcredit = ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech.
            ls_result-closingdebit = 0.
          ELSEIF ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech < 0.
            ls_result-closingcredit = 0.
            ls_result-closingdebit = abs( ls_result-closingcredit - ls_result-closingdebit - lv_chenh_lech ).
          ENDIF.

          ls_line_item-debit_amount = COND #( WHEN ls_ko_phat_sinh_faglfcv-target_currency = 'VND'
                                              THEN ls_line_item-debit_amount * 100
                                              ELSE ls_line_item-debit_amount ) .
          ls_line_item-credit_amount = COND #( WHEN ls_ko_phat_sinh_faglfcv-target_currency = 'VND'
                                               THEN ls_line_item-credit_amount * 100
                                               ELSE ls_line_item-credit_amount ) .

          APPEND ls_line_item TO lt_line_items.
          CLEAR: ls_line_item.
        ENDLOOP.

        " Convert line items to JSON
        ls_result-lineitemsjson = convert_line_items_to_json( lt_line_items ).

        ls_result-postingdatefrom = lv_date_from.
        ls_result-postingdateto = lv_date_to.

        APPEND ls_result TO lt_result.
        CLEAR: ls_result, ls_ko_phat_sinh, ls_open_balances_faglfcv, ls_ko_phat_sinh_faglfcv, ls_line_item, lt_line_items.
      ENDIF.
    ENDLOOP.

    " Nếu tran curency = 'VND', bỏ tran amount chỉ lấy company amount.
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      IF ( <fs_result>-transactioncurrency = 'VND' AND <fs_result>-thanhtoannt NE 'X' ) OR ls_curr-low = 'VND'.
        CLEAR:
        <fs_result>-openingcreditbalancetran,
        <fs_result>-openingdebitbalancetran,
        <fs_result>-creditamountduringperiodtran,
        <fs_result>-debitamountduringperiodtran,
        <fs_result>-closingcredittran,
        <fs_result>-closingdebittran.
      ENDIF.
      IF <fs_result>-transactioncurrency = 'VND' AND <fs_result>-thanhtoannt = 'X'.
        <fs_result>-transactioncurrency = 'USD'.
      ENDIF.
    ENDLOOP.

    " 4. Sorting
    DATA(sort_order) = VALUE abap_sortorder_tab(
      FOR sort_element IN io_request->get_sort_elements( )
                          ( name = sort_element-element_name descending = sort_element-descending ) ).
    IF sort_order IS NOT INITIAL.
      SORT lt_result BY (sort_order).
    ENDIF.

    DATA(lv_total_records) = lines( lt_result ).

    DATA(lo_paging) = io_request->get_paging( ).
    IF lo_paging IS BOUND.
      DATA(top) = lo_paging->get_page_size( ).
      IF top < 0. " -1 means all records
        top = lv_total_records.
      ENDIF.
      DATA(skip) = lo_paging->get_offset( ).

      IF skip >= lv_total_records.
        CLEAR lt_result. " Offset is beyond the total number of records
      ELSEIF top = 0.
        CLEAR lt_result. " No records requested
      ELSE.
        " Calculate the actual range to keep
        DATA(lv_start_index) = skip + 1. " ABAP uses 1-based indexing
        DATA(lv_end_index) = skip + top.

        " Ensure end index doesn't exceed table size
        IF lv_end_index > lv_total_records.
          lv_end_index = lv_total_records.
        ENDIF.

        " Create a new table with only the required records
        DATA: lt_paged_result LIKE lt_result.
        CLEAR lt_paged_result.

        " Copy only the required records
        DATA(lv_index) = lv_start_index.
        WHILE lv_index <= lv_end_index.
          APPEND lt_result[ lv_index ] TO lt_paged_result.
          lv_index = lv_index + 1.
        ENDWHILE.

        lt_result = lt_paged_result.
      ENDIF.
    ENDIF.
    " 6. Set response
    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_result ) ).
    ENDIF.
  ENDMETHOD.


  METHOD process_period_data.
    DATA: ls_line_item       TYPE ty_line_item,
          lt_open_balances   TYPE TABLE OF zst_open_balances,
          lv_running_balance TYPE wrbtr.
    lt_open_balances = it_open_balances.
    CLEAR: et_line_items, ev_debit_total, ev_credit_total.

    " Sort by date and document
    DATA(lt_journal_items) = it_journal_items.
    SORT lt_journal_items BY postingdate accountingdocument.

    DATA(lt_in_faglfcv) = it_in_faglfcv.
    SORT lt_in_faglfcv BY ccode account gl_account.

*    DATA: lt_where_clauses TYPE TABLE OF string.
*
*    APPEND | customer = @iv_partner| TO lt_where_clauses.
*    APPEND |AND postingdate < @iv_date_from| TO lt_where_clauses.
*    APPEND |AND companycode = @iv_bukrs| TO lt_where_clauses.
*    APPEND |AND ledger = '0L'| TO lt_where_clauses.
*    APPEND |AND financialaccounttype = 'D'| TO lt_where_clauses.
*    APPEND |AND customer IS NOT NULL| TO lt_where_clauses.
*    APPEND |AND glaccount = @iv_racct| TO lt_where_clauses.
*    APPEND |AND debitcreditcode IN ('S', 'H')| TO lt_where_clauses.
*
*    IF iv_currency IS NOT INITIAL.
*      APPEND |AND transactioncurrency = @iv_currency| TO lt_where_clauses.
*    ENDIF.
*
*    SELECT customer AS bp,
*           companycode AS rbukrs,
*           SUM( CASE WHEN debitcreditcode = 'S' THEN amountincompanycodecurrency ELSE 0 END ) AS open_debit,
*           SUM( CASE WHEN debitcreditcode = 'H' THEN amountincompanycodecurrency ELSE 0 END ) AS open_credit,
*           SUM( CASE WHEN debitcreditcode = 'S' THEN amountintransactioncurrency ELSE 0 END ) AS open_debit_tran,
*           SUM( CASE WHEN debitcreditcode = 'H' THEN amountintransactioncurrency ELSE 0 END ) AS open_credit_tran,
*           transactioncurrency,
*           companycodecurrency,
*           glaccount
*      FROM i_journalentryitem
*      WHERE (lt_where_clauses)
*      GROUP BY customer, companycode, transactioncurrency, companycodecurrency, glaccount
*      INTO TABLE @DATA(lt_open_balances).

    SORT lt_open_balances BY bp rbukrs.
    READ TABLE lt_open_balances INTO DATA(ls_open_balance) WITH KEY bp = iv_partner rbukrs = iv_bukrs.
*        lấy diễn dải mới cho cho doc.type RV
    DATA: lt_text_i TYPE tt_text,
          lt_text_o TYPE tt_text.
    DATA(lt_rv) = lt_journal_items[].
    DELETE lt_rv WHERE accountingdocumenttype <> 'RV'.
    IF lt_rv[] IS NOT INITIAL.
      SELECT DISTINCT
      accountingdocument,
      originalreferencedocument
        FROM i_operationalacctgdocitem
        FOR ALL ENTRIES IN @lt_rv
        WHERE accountingdocument = @lt_rv-accountingdocument
        AND fiscalyear = @lt_rv-fiscalyear
        AND companycode = @iv_bukrs
        AND originalreferencedocument <> ''
        INTO  TABLE @DATA(lt_referrv).
      IF sy-subrc = 0.
        LOOP AT lt_referrv INTO DATA(ls_referrv).
          APPEND INITIAL LINE TO lt_text_i ASSIGNING FIELD-SYMBOL(<fs_text_1>).
          <fs_text_1>-billing = ls_referrv-originalreferencedocument.
          <fs_text_1>-belnr = ls_referrv-accountingdocument.
        ENDLOOP.
        SORT lt_text_i BY billing.
        DELETE ADJACENT DUPLICATES FROM lt_text_i COMPARING billing.
        get_longtext_outbound(
          EXPORTING
            tt_text_i = lt_text_i
          IMPORTING
            tt_text_o = lt_text_o
        ).
      ENDIF.
    ENDIF.
    " Get account nature for balance calculation
    DATA(lv_account_nature) = determine_account_nature( iv_racct ).

    LOOP AT lt_journal_items INTO DATA(ls_item).
      CLEAR ls_line_item.
      IF ls_item-accountingdocumenttype = 'RV'.
        READ TABLE lt_text_o INTO DATA(ls_text) WITH KEY belnr = ls_item-accountingdocument BINARY SEARCH.
        IF sy-subrc = 0.
          ls_item-documentitemtext = ls_text-text.
        ELSE.
          CLEAR: ls_item-documentitemtext.
        ENDIF.
      ENDIF.

      ls_line_item-posting_date = ls_item-postingdate.
      ls_line_item-document_number = ls_item-accountingdocument.
      ls_line_item-document_date = ls_item-documentdate.
      ls_line_item-transactioncurrency = iv_currency.
      ls_line_item-companycodecurrency = ls_item-companycodecurrency.
      ls_line_item-profit_center = ls_item-profitcenter.

      " Get contra account
      ls_line_item-contra_account = get_contra_account(
        iv_bukrs                  = ls_item-companycode
        iv_accountingdoc          = ls_item-accountingdocument
        iv_fiscalyear             = ls_item-fiscalyear
        iv_racct                  = ls_item-glaccount
        iv_lineitem               = ls_item-ledgergllineitem
        iv_accountingdocumentitem = ls_item-accountingdocumentitem
      ).

      " Set text
      ls_line_item-item_text = ls_item-documentitemtext.

      IF ls_line_item-item_text IS INITIAL.
        SELECT SINGLE accountingdocumentheadertext
          FROM i_journalentry
          WHERE companycode = @ls_item-companycode
          AND accountingdocument = @ls_item-accountingdocument
          AND fiscalyear = @ls_item-fiscalyear
          INTO @DATA(ls_doc_header_text).

        ls_line_item-item_text = ls_doc_header_text.
      ENDIF.

      " Determine debit/credit amounts
      IF ls_item-debitcreditcode = 'S'.
        ls_line_item-debit_amount = ls_item-amountincompanycodecurrency.
        ev_debit_total = ev_debit_total + ls_line_item-debit_amount.
        " transaction currency
        IF ls_line_item-transactioncurrency NE 'VND'.
          ls_line_item-debit_amount_tran = ls_item-amountintransactioncurrency.
          ev_debit_total_tran = ev_debit_total_tran + ls_line_item-debit_amount_tran.
        ENDIF.
      ELSE.
        " Kiem tra them case thanh toan ngoai te VND
*        IF ls_item-financialaccounttype = 'D' AND ( ls_item-accountingdocument NE ls_item-clearingaccountingdocument ) AND ls_item-transactioncurrency = 'VND'.
*          SELECT
*           SUM( amountintransactioncurrency ) AS amountintransactioncurrency ,
*           transactioncurrency,
*           supplier,
*           glaccount
*           FROM i_journalentryitem
*           WHERE accountingdocument = @ls_item-clearingaccountingdocument
*           AND   companycode = @ls_item-companycode
*           AND fiscalyear = @ls_item-fiscalyear
*           AND debitcreditcode = 'S'
*           AND transactioncurrency NE 'VND'
*           AND financialaccounttype = 'D'
*           AND ledger = '0L'
*           GROUP BY transactioncurrency, supplier, glaccount
*           INTO TABLE @DATA(lt_sum).
*          READ TABLE lt_sum INTO DATA(ls_sum) INDEX 1.
*          IF sy-subrc = 0.
*            IF ls_sum-amountintransactioncurrency > 0.
*              ls_sum-amountintransactioncurrency = ls_sum-amountintransactioncurrency * -1.
*            ENDIF.
*            ls_line_item-thanhtoannt = 'X'.
*            ls_line_item-transactioncurrency = ls_sum-transactioncurrency.
*            ls_line_item-credit_amount_tran = ls_sum-amountintransactioncurrency.
*            ls_item-amountintransactioncurrency = ls_sum-amountintransactioncurrency.
*          ENDIF.
*        ENDIF.
        ls_line_item-credit_amount = ls_item-amountincompanycodecurrency * -1.
        ev_credit_total = ev_credit_total + ls_line_item-credit_amount.
        " transaction currency
        IF ls_line_item-transactioncurrency NE 'VND'.
          ls_line_item-credit_amount_tran = ls_item-amountintransactioncurrency * -1.
          ev_credit_total_tran = ev_credit_total_tran + ls_line_item-credit_amount_tran.
        ENDIF.
      ENDIF.

      IF ls_open_balance-open_debit + ls_open_balance-open_credit + ev_debit_total - ev_credit_total > 0.
        ls_line_item-closingdebit = ls_open_balance-open_debit + ls_open_balance-open_credit + ev_debit_total - ev_credit_total.
        ls_line_item-closingcredit = 0.
      ELSE.
        ls_line_item-closingcredit = ( ls_open_balance-open_debit + ls_open_balance-open_credit + ev_debit_total - ev_credit_total ) * -1.
        ls_line_item-closingdebit = 0.
      ENDIF.
      " transaction currency closing amounts
      IF ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran + ev_debit_total_tran - ev_credit_total_tran > 0.
        ls_line_item-closingdebit_tran = ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran + ev_debit_total_tran - ev_credit_total_tran.
        ls_line_item-closingcredit_tran = 0.
      ELSE.
        ls_line_item-closingcredit_tran = ( ls_open_balance-open_debit_tran + ls_open_balance-open_credit_tran + ev_debit_total_tran - ev_credit_total_tran ) * -1.
        ls_line_item-closingdebit_tran = 0.
      ENDIF.

      ls_line_item-debit_amount = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                          THEN ls_line_item-debit_amount * 100
                                          ELSE ls_line_item-debit_amount ) .
      ls_line_item-credit_amount = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                           THEN ls_line_item-credit_amount * 100
                                           ELSE ls_line_item-credit_amount ) .
      ls_line_item-debit_amount_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                               THEN ls_line_item-debit_amount_tran * 100
                                               ELSE ls_line_item-debit_amount_tran ).
      ls_line_item-credit_amount_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                                THEN ls_line_item-credit_amount_tran * 100
                                                ELSE ls_line_item-credit_amount_tran ).
      ls_line_item-closingdebit = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                          THEN ls_line_item-closingdebit * 100
                                          ELSE ls_line_item-closingdebit ) .
      ls_line_item-closingcredit = COND #( WHEN ls_line_item-companycodecurrency = 'VND'
                                           THEN ls_line_item-closingcredit * 100
                                           ELSE ls_line_item-closingcredit ) .
      ls_line_item-closingdebit_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                               THEN ls_line_item-closingdebit_tran * 100
                                               ELSE ls_line_item-closingdebit_tran ).
      ls_line_item-closingcredit_tran = COND #( WHEN ls_line_item-transactioncurrency = 'VND'
                                                THEN ls_line_item-closingcredit_tran * 100
                                                ELSE ls_line_item-closingcredit_tran ).
      APPEND ls_line_item TO et_line_items.
      CLEAR: ls_line_item.
    ENDLOOP.

    IF lt_in_faglfcv IS NOT INITIAL.
      DATA: lv_chenh_lech TYPE zui_in_faglfcv-posting_amount.

      LOOP AT lt_in_faglfcv INTO DATA(ls_in_faglfcv).
        lv_chenh_lech = ls_in_faglfcv-debit_faglfcv + ls_in_faglfcv-credit_faglfcv.

        ls_line_item-posting_date = ls_in_faglfcv-keydate.
*        ls_line_item-document_number = ls_in_faglfcv-doc_number.
        ls_line_item-document_number = ||.
        ls_line_item-document_date = ls_in_faglfcv-keydate.
        ls_line_item-transactioncurrency = ls_in_faglfcv-currency.
        ls_line_item-companycodecurrency = ls_in_faglfcv-target_currency.
        ls_line_item-item_text = |Đánh giá chênh lệch tỷ giá|.

        IF lv_chenh_lech > 0.
          ls_line_item-contra_account = '5151001010'.

          ls_line_item-debit_amount = lv_chenh_lech.
          ev_debit_total = ev_debit_total + ls_line_item-debit_amount.
        ELSE.
          ls_line_item-contra_account = '6351001000'.

          ls_line_item-credit_amount = lv_chenh_lech * -1.
          ev_credit_total = ev_credit_total + ls_line_item-credit_amount.
        ENDIF.

        IF ls_in_faglfcv-keydate+6(2) = 1.
          IF lv_chenh_lech < 0.
            ls_line_item-contra_account = '5151001010'.
          ELSE.
            ls_line_item-contra_account = '6351001000'.
          ENDIF.
        ENDIF.

        IF ls_open_balance-open_debit + ls_open_balance-open_credit + lv_chenh_lech + ev_debit_total - ev_credit_total > 0.
          ls_line_item-closingdebit = ls_open_balance-open_debit + ls_open_balance-open_credit + lv_chenh_lech + ev_debit_total - ev_credit_total.
          ls_line_item-closingcredit = 0.
        ELSE.
          ls_line_item-closingcredit = ( ls_open_balance-open_debit + ls_open_balance-open_credit + lv_chenh_lech + ev_debit_total - ev_credit_total ) * -1.
          ls_line_item-closingdebit = 0.
        ENDIF.

        ls_line_item-debit_amount = COND #( WHEN ls_in_faglfcv-target_currency = 'VND'
                                            THEN ls_line_item-debit_amount * 100
                                            ELSE ls_line_item-debit_amount ) .
        ls_line_item-credit_amount = COND #( WHEN ls_in_faglfcv-target_currency = 'VND'
                                             THEN ls_line_item-credit_amount * 100
                                             ELSE ls_line_item-credit_amount ) .

        APPEND ls_line_item TO et_line_items.
        CLEAR: ls_line_item.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_longtext_outbound.
    CHECK tt_text_i[] IS NOT INITIAL.
    SELECT DISTINCT referencesddocument, billingdocument
        FROM i_billingdocumentitem
        FOR ALL ENTRIES IN @tt_text_i
        WHERE billingdocument = @tt_text_i-billing
        INTO TABLE @DATA(lt_outbound).


    DATA: lw_username TYPE string,
          lw_password TYPE string,
          lv_url      TYPE string,
          e_code      TYPE i,
          lv_response TYPE string,
          e_response  TYPE string.
    SELECT SINGLE * FROM ztb_api_auth
    WHERE systemid = 'CASLA'
  INTO @DATA(ls_api_auth).

    lw_username = ls_api_auth-api_user.
    lw_password = ls_api_auth-api_password.
    LOOP AT lt_outbound INTO DATA(ls_outbound).
      APPEND INITIAL LINE TO tt_text_o ASSIGNING FIELD-SYMBOL(<fs_output>).
      <fs_output>-billing = ls_outbound-billingdocument.
      <fs_output>-outbound = ls_outbound-referencesddocument.
      READ TABLE tt_text_i INTO DATA(ls_input) WITH KEY billing = ls_outbound-billingdocument.
      IF sy-subrc = 0.
        <fs_output>-belnr = ls_input-belnr.
      ENDIF.
      DATA(tmp) = |{ ls_outbound-referencesddocument ALPHA = OUT }|.
      CONDENSE tmp.
      lv_url = |https://{ ls_api_auth-api_url }/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('{ tmp }')/to_DeliveryDocumentText|.

      TRY.

          DATA(lo_http_destination) =
            cl_http_destination_provider=>create_by_url( lv_url ).

          DATA(lo_web_http_client) =
            cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
          DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).

          "Authorization
          lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'PB9_LO' ).
          lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Qwertyuiop@1234567890' ).

          lo_web_http_request->set_authorization_basic( i_username = lw_username i_password = lw_password ).
          lo_web_http_request->set_content_type( |application/json| ).



          DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).
          lv_response = lo_web_http_response->get_text( ).

          /ui2/cl_json=>deserialize(
            EXPORTING
              json = lv_response
            CHANGING
              data = e_response ).
          DATA(lv_status) = lo_web_http_response->get_status( ).
          DATA(lv_body)   = lo_web_http_response->get_text( ).

        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.

      ENDTRY.
      IF lv_status-code = '200'.
*        DATA: ls_text TYPE lty_longtxt.
        SPLIT lv_response AT '</d:DeliveryDocument>' INTO TABLE DATA(lt_entry).

        LOOP AT lt_entry INTO DATA(lv_entry).

          " Lấy LongTextID
          FIND FIRST OCCURRENCE OF '<d:TextElement>' IN lv_entry.
          IF sy-subrc = 0.
            SPLIT lv_entry AT '<d:TextElement>' INTO DATA(lv_dummy) DATA(lv_tmp).
            SPLIT lv_tmp   AT '</d:TextElement>' INTO DATA(id) DATA(lv_dummy2).
          ENDIF.

          " Lấy LongText
          IF id = 'Z006'.
            FIND FIRST OCCURRENCE OF '<d:TextElementText>' IN lv_entry.
            IF sy-subrc = 0.
              SPLIT lv_entry AT '<d:TextElementText>' INTO lv_dummy lv_tmp.
              SPLIT lv_tmp   AT '</d:TextElementText>' INTO DATA(cont) DATA(lv_dummy3).
            ENDIF.
          ELSEIF id = 'Z029'.
            FIND FIRST OCCURRENCE OF '<d:TextElementText>' IN lv_entry.
            IF sy-subrc = 0.
              SPLIT lv_entry AT '<d:TextElementText>' INTO lv_dummy lv_tmp.
              SPLIT lv_tmp   AT '</d:TextElementText>' INTO DATA(seal) lv_dummy3.
            ENDIF.
          ENDIF.
        ENDLOOP.
        <fs_output>-text = |Xuất bán theo Cont/Seal: { cont }/{ seal }|.
      ENDIF.
      CLEAR: lv_status, lv_response.
    ENDLOOP.

    SORT tt_text_o BY belnr.
  ENDMETHOD.
ENDCLASS.
