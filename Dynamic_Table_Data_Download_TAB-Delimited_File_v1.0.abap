*&---------------------------------------------------------------------*
*& Report ZTABLE_DATA_EXTRACVT_BTP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_data.

* program to download data from any database table
* Dynamic table data download to Tab-delimited file

TYPES : BEGIN OF gty_det,
          tabname   TYPE tabname,
          fieldname TYPE fieldname,
          index     TYPE i,
        END OF gty_det,

        BEGIN OF gty_text,
          text(2500) TYPE c,
        END OF gty_text.

DATA : lt_table_filds      TYPE TABLE OF dfies,
       lt_dref             TYPE REF TO data,
       ls_dref             TYPE REF TO data,
       lt_dd30l            TYPE STANDARD TABLE OF dd03l,
       ls_dd30l            TYPE dd03l,
       lt_tbl_fld          TYPE STANDARD TABLE OF gty_det,
       ls_tbl_fld          TYPE gty_det,
       lv_variable_1(500)  TYPE c, "char100,
       lv_variable_2(2500) TYPE c,
       lv_field            TYPE char30,
       lt_text             TYPE STANDARD TABLE OF gty_text,
       ls_text             TYPE gty_text,
       gv_table            TYPE tabname16,
       gv_path             TYPE string,
       lv_filename         TYPE string,
       lv_file             TYPE string,
       lv_path             TYPE string,
       lv_file_name        TYPE string,
       lv_count            TYPE i,
       lv_temp(2500)       TYPE c,
       lv_val_1            TYPE i,
       lv_val_2            TYPE i,
       lv_total            TYPE i.

*** --- Field Symbols
FIELD-SYMBOLS : <fld_value> TYPE any.
FIELD-SYMBOLS : <fs_table> TYPE any.
FIELD-SYMBOLS : <ft_table> TYPE STANDARD TABLE.
FIELD-SYMBOLS : <dyn_field>.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
PARAMETER:rad1 RADIOBUTTON GROUP rad USER-COMMAND frad1 DEFAULT 'X',
          p_table TYPE tabname16 MODIF ID aa,

          rad2 RADIOBUTTON GROUP rad.
SELECT-OPTIONS s_table FOR gv_table NO INTERVALS MODIF ID bb.
PARAMETERS:sel_fold TYPE string OBLIGATORY MODIF ID bb.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.

  IF rad1 = 'X'.

    LOOP AT SCREEN.
      IF screen-group1 = 'AA'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group1 = 'BB'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSEIF rad2 = 'X'.

    LOOP AT SCREEN.
      IF screen-group1 = 'AA'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group1 = 'BB'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR sel_fold.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Select Directory'
      initial_folder       = 'c:\'
    CHANGING
      selected_folder      = sel_fold
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE 'Directory selection Error' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.
* Create OBJECT lr_descr.

  IF rad1 EQ abap_true.
    PERFORM process USING p_table.
  ELSEIF rad2 EQ abap_true.

* Loop the select options and pass the value inside the perform
    gv_path = sel_fold.

    DESCRIBE TABLE s_table LINES DATA(lv_lines).

    LOOP AT s_table INTO DATA(ls_table).
      gv_table = ls_table-low.

      IF sy-tabix EQ lv_lines.
        DATA(gv_flag) = abap_true.
      ENDIF.

      PERFORM process USING gv_table.

      CLEAR : lv_filename, lv_file, ls_table, gv_table, lt_text, lv_count.
    ENDLOOP.

  ENDIF.
*&---------------------------------------------------------------------*
*& Form PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_TABLE
*&---------------------------------------------------------------------*
FORM process USING pv_table TYPE tabname16.

*** --- Assigning fields symbols for Tables
  CREATE DATA lt_dref TYPE TABLE OF (pv_table).
  CREATE DATA ls_dref TYPE (pv_table).

*** --- Assign field symbol with table type of DDIC
  ASSIGN lt_dref->* TO <ft_table>.

*** --- Assign field symbol with Structure type of DDIC
  ASSIGN ls_dref->* TO <fs_table>.

  SELECT *
  FROM (pv_table)
  INTO TABLE <ft_table>.

  IF sy-subrc EQ 0.

    lv_filename = pv_table.

    IF rad1 EQ abap_true.

      CALL METHOD cl_gui_frontend_services=>file_save_dialog
        EXPORTING
          window_title              = 'Save Form'
          default_extension         = 'txt'
          default_file_name         = lv_filename
          prompt_on_overwrite       = 'X'
        CHANGING
          filename                  = lv_file_name
          path                      = lv_path
          fullpath                  = lv_file
        EXCEPTIONS
          cntl_error                = 1
          error_no_gui              = 2
          not_supported_by_gui      = 3
          invalid_default_file_name = 4
          OTHERS                    = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        MESSAGE 'File Process Error' TYPE 'E'.
      ENDIF.

    ELSEIF rad2 EQ abap_true.

      CONCATENATE gv_path '\' lv_filename '.txt' INTO lv_file.

    ENDIF.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_file
        filetype                = 'DAT'
        write_field_separator   = 'X'
      TABLES
        data_tab                = <ft_table>
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
    IF sy-subrc IS NOT INITIAL.
* Implement suitable error handling here
      MESSAGE 'File Process Error' TYPE 'E'.
    ENDIF.
  ENDIF.

  IF rad2 EQ abap_true
  AND gv_flag EQ abap_true.
    MESSAGE 'All files downloaded' TYPE 'I'.
  ENDIF.

ENDFORM.
