;Contrôler la place disque
;Faire des jauges
;Avertissement si atteinte limite (seuil)
;Stage ###
;faire une vidéo du moniteur présentant le théme de la séance
; à insérer en tête de vidéo de stage, à chaque session par exemple
;Ingres, Jeff Koons, Francis Bacon, Bill Viola, Gary Hill, Jérôme Bosh, Diane Arbus, Richard Avedon, Guido Mocafico, Le Corbusier, Tadao Ando ...

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("MustDeclareVars", 0)       ;0=no, 1=require pre-declare

;includes SYSTEM
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <String.au3>
#include <GuiComboBox.au3>
#include <GuiStatusBar.au3>

;includes SYSTEM.modifiés
#include "#include.autoit\FTPEx.au3"

;includes PERSO
#include "#include\declarations_init.au3"
#include "#include\operations_INI-FORMS.au3"
#include "#include\func_OBS.au3"
#include "#include\func_GEN.au3"
#include "#include\export_WEB-virtuemart.au3"
#include "#include\BDD_management.au3"

;includes WEB.UDF
#include "#include.web\DateFR.au3"
#include "#include.web\mediainfo.au3"
#include "#include.web\accents.au3"
#include "#include.web\TimeDiff.au3"

;KXF
#include "#form\Mooviideo_WIN.au3"
GUISetState(@SW_SHOW)
;GUICtrlSetState($VIDEOacquisition, $GUI_HIDE)

fChargement_ini_General()
fChargement_ini_Lieu()
fChargement_ini_Org()
fChargement_ini_ConcoursFFE()
fChargement_ini_ConcoursLIB()
fChargement_ini_OBScmd()
fChargement_ini_OBSficdos()
fChargement_ini_MESPUB()
fChargement_ini_RECORD_ACQ()
fChargement_ini_CEJ()
fChargement_ini_TRT()
fChargement_ini_OUT()

;TODO - passer en variable le type de concours
;fCharg_zcommun("CONFFE")
fChargement_forms()
;onglet concoursFFE
fChargement_forms_list($vg_type_eve_FFE)
;onglet concoursLIBRE
fCharg_zcommun($vg_type_eve_LIB)
fChargement_forms_list($vg_type_eve_LIB)
fChargement_listview_epreuve_libre(0)
;
fChargement_forms_list("GENERALES")

;zones communes
fCharg_zcommun($vg_type_evenement)
fChargement_forms_zcommun()

;onglet VIDEOacquisition
fChargement_listview_epreuve($vg_type_evenement)



;Global $vWin1="VidBlaster Broadcast"
;Global $vWin2="Information"
;Global $vgSection="EQUI"
;Local $vl_record_date_forme1, $vl_record_date_forme2 ; 01/01/2013 et 20130101
;Local $vl_record_time_forme1, $vl_record_time_forme2 ; 10:44 et 104450650 soir 10h 44m 50sec 650 millisec
;Local $vl_bottom_line1, $vl_bottom_line2
;Local $vl_bcl_max_ban	= 500
;Local $vl_bcl_max_oo	= 500
;Local $vl_bcl_caract_oo = "0"
;Local $vl_type_pub		= 2							;1:bannière 2:one/one
;Local $vl_button_state_record = 0					;0:inactif 1:actif 2:RECORD en cours/bouton à activer
;Local $vl_button_state_stop_save = 0				;0:inactif 1:actif 2:STOP/SAVE en cours/bouton à activer
;Local $vl_button_state_abort = 0					;0:inactif 1:actif 2:ABORT en cours/bouton à activer
;Local $vl_button_test_streaming_text

;Init.OBS
;Si bouton RECORD est déjà actif
$vl_button_record_text = ControlGetText($vg_ini_obscmd_basic_window_info_class,"",$vg_ini_obscmd_enregistrement_go)
$vl_button_test_streaming_text = ControlGetText($vg_ini_obscmd_basic_window_info_class,"",$vg_ini_obscmd_test_streaming_go)
;MsgBox(0,"",$vl_button_record_text & "/" & $vl_button_test_streaming_text)
if $vl_button_record_text = $vg_ini_obscmd_enregistrement_stop_text Then
	;Abandon de l'enregistrement en cours
	fObs_record_stop()
EndIf

;Si bouton TEST STREAMING est déjà actif
if $vl_button_test_streaming_text = $vg_ini_obscmd_test_streaming_stop_text Then
	;Abandon de l'enregistrement en cours
	fObs_test_stop()
EndIf

;Désactivation ligne 5
fOBS_posit_ligne("PUB","")
fObs_trt_ficvideo()

fSET_autoit_session_datetime()

fHotkey("OFF")

While 1
	$nMsg = GUIGetMsg()

	if $vg_record = 1 Then
		;record en cours
		$vg_timer_diff = Round(TimerDiff($vg_timer_init) / 1000,0)	;secondes
		if $vg_timer_diff > $vg_timer_diff_mem Then
			$vg_timer_mn = Int($vg_timer_diff / 60)		;minutes
			$vl_timer_ss = $vg_timer_mn * 60			;minutes pleines en secondes
			$vl_timer_ss = $vg_timer_diff - $vl_timer_ss
			;msgbox (0,"x", $vg_timer_diff & "/" & $vg_timer_diff_mem & "/" & $vg_timer_mn & "/" & $vl_timer_ss)
			;Afficher secondes
			GUICtrlSetData($vf_label_ss,StringFormat("%02i",$vl_timer_ss))
			;Afficher minutes
			if $vg_timer_mn <> $vg_timer_mn_mem Then
				GUICtrlSetData($vf_label_mn,StringFormat("%02i",$vg_timer_mn))
				$vg_timer_mn_mem = $vg_timer_mn
			EndIf
			$vg_timer_diff_mem = $vg_timer_diff
		EndIf
		If $vg_timer_diff > 15 Then
			Switch StringUpper(StringLeft(GUICtrlRead($vf_com_con_phase),3))
				Case "EPR","BAR"
						$vl_msg_contenu = ""
						$vl_i = 0
						if GUICtrlRead($vf_commun_cavalier) <> "" Then
							If GUICtrlRead($vf_commun_cavalier) = "Sous X" or GUICtrlRead($vf_commun_cavalier) = "Engagement Terrain" Then
								$vl_msg_contenu = $vl_msg_contenu & GUICtrlRead($vf_commun_cavalier)
								$vl_i = $vl_i + 1
							Else
								$vl_msg_contenu = $vl_msg_contenu & "Cavalier/" & GUICtrlRead($vf_commun_cavalier)
								$vl_i = $vl_i + 1
							EndIf
						EndIf
						If GUICtrlRead($vf_commun_cheval) <> "" Then
							if $vl_i > 0 Then
								$vl_msg_contenu = $vl_msg_contenu & "   "
								$vl_i = $vl_i - 1
							EndIf
							$vl_msg_contenu = $vl_msg_contenu & "Cheval/" & GUICtrlRead($vf_commun_cheval)
							$vl_i = $vl_i + 1
						EndIf
						if GUICtrlRead($vf_commun_centre) <> "" Then
							if $vl_i > 0 Then
								$vl_msg_contenu = $vl_msg_contenu & "   "
								$vl_i = $vl_i - 1
							EndIf
							$vl_msg_contenu = $vl_msg_contenu & "Centre/" & GUICtrlRead($vf_commun_centre)
							$vl_i = $vl_i + 1
						EndIf

						if $vl_msg_contenu <> "" Then
							$vl_msg_contenu =  "[" & $vl_msg_contenu & "]"
						EndIf

						if $vl_msg_contenu <> $vg_msg_contenu_mem Then
							fOBS_posit_ligne2()
							$vg_msg_contenu_mem = $vl_msg_contenu
						EndIf
			EndSwitch
		EndIf
	EndIf

	;Traitement VIDEO
	$vg_bcl_elapse_genmedia_rang = $vg_bcl_elapse_genmedia_rang + 1
	if $vg_bcl_elapse_genmedia_rang > $vg_bcl_elapse_genmedia_max Then
		fAna_trt_video()
		$vg_bcl_elapse_genmedia_rang = 0
	EndIf

	;Sélection dans la listview epreuve en fonction du rang saisie
	$vg_bcl_elapse_rang = $vg_bcl_elapse_rang + 1
	if $vg_bcl_elapse_rang > $vg_bcl_elapse_rang_max Then
		;$vl_label_rang_depart
		$vg_rang_depart = GUICtrlRead($vf_label_rang_depart)

		if $vg_rang_depart_mem <> $vg_rang_depart Then
			$vg_rang_depart_mem = $vg_rang_depart
			if $vg_rang_depart = 999 Then
				;engagement terrain
				fRang_capture(999)
			Else
				;ConsoleWrite("INPUT/$input1/" & $vg_rang_depart & @CRLF)
				$lw_rang = 0
				For $vl_array_i = 0 to ubound($vg_array_tab) - 1
					if stringleft($vg_array_tab [$vl_array_i],3) = StringFormat("%03i",$vg_rang_depart) Then
						$lw_rang = $vl_array_i
						ConsoleWrite("INPUT/$lw_rang1/" & $lw_rang & @CRLF)
						ExitLoop
					EndIf
				Next
				$vg_array_i = $lw_rang
				if $lw_rang = 0 Then
					;_GUICtrlListView_ClickItem($listview1, 0, "left", False, 2)
					;aucune correspondance dans la listview
					fRang_capture(0)
				Else
					;_GUICtrlListView_EnsureVisible($listview1, $lw_rang)
					_GUICtrlListView_ClickItem($vf_epreuve_listview, $lw_rang-1, "left", False, 2)
					fRang_capture($lw_rang)
				EndIf
			EndIf
		EndIf
	EndIf

	;Déplacement fichiers
	$vg_bcl_elapse_trt = $vg_bcl_elapse_trt + 1
	;$vg_bcl_elapse_trt = 0
	if $vg_bcl_elapse_trt > $vg_bcl_elapse_trt_max Then
		;TRT save
		$vl_path_tempo_save = $vg_ini_recordacq_drive & "\" & $vg_ini_recordacq_dossier_niv0 & "\" & $vg_ini_recordacq_dossier_niv1 & "\" & $vg_ini_recordacq_dossier_niv2_tmpsave
		$vl_path_trt = $vg_ini_trt_drive & "\" & $vg_ini_trt_dossier_niv0_1  & "\" & $vg_ini_trt_dossier_niv1_1  & "\" & $vg_ini_trt_dossier_niv2_1
		;Déplacement fichier video
		$vl_file_status = FileMove($vl_path_tempo_save & "\*." & $vg_ini_recordacq_fichier_ext_video, $vl_path_trt & "\*." & $vg_ini_recordacq_fichier_ext_video, $FC_OVERWRITE+$FC_CREATEPATH )
		;Déplacement fichier info (pour finaliser le déplacement)
		$vl_file_status = FileMove($vl_path_tempo_save & "\*." & $vg_ini_recordacq_fichier_ext_info, $vl_path_trt & "\*." & $vg_ini_recordacq_fichier_ext_info, $FC_OVERWRITE+$FC_CREATEPATH )
		;ConsoleWrite("TRT/" & $vl_file_status & @CRLF)
		$vl_bcl_elapse_trt = 0
	EndIf

	$vg_bcl_elapse_out = $vg_bcl_elapse_out + 1
	if $vg_bcl_elapse_out > $vg_bcl_elapse_out_max Then
		;OUT
		;lecture dossier IN
		$vl_path_trt_base = $vg_ini_trt_drive & "\" & $vg_ini_trt_dossier_niv0_1  & "\" & $vg_ini_trt_dossier_niv1_1  & "\"
		$vl_path_trt = $vl_path_trt_base & $vg_ini_trt_dossier_niv2_1 & "\"
		$vl_path_err = $vl_path_trt_base & $vg_ini_trt_dossier_niv2_2 & "\"

		$vl_path_out_base = $vg_ini_out_drive & "\" & $vg_ini_out_dossier_niv0_1  & "\" & $vg_ini_out_dossier_niv1_1  & "\"
		$vl_path_out_pub_libre = $vl_path_out_base & $vg_ini_out_dossier_niv2_3 & "\"
		$vl_path_out_pub_restreint = $vl_path_out_base & $vg_ini_out_dossier_niv2_7 & "\"
		$vl_path_out_web = $vl_path_out_base & $vg_ini_out_dossier_niv2_4 & "\"

		$vl_array_filelist = _FileListToArray($vl_path_trt, "*.*")
		If @error = 1 Then
			Consolewrite("Path was invalid" & @CRLF)
		Else
			If @error = 4 Then
				;Consolewrite("Pas de fichier(s) à traiter" & @CRLF)
			Else
				;traitement
				$vl_i_filelist_max = UBound($vl_array_filelist)
				;ConsoleWrite($vl_i_filelist_max & @CRLF)
				;_ArrayDisplay($vl_filelist, "$vl_filelist")
				For $vl_i_filelist = 1 to $vl_i_filelist_max - 1; subtract 1 from size to prevent an out of bounds error
					;ConsoleWrite($vl_path_trt & $vl_filelist[$i] & @CRLF)
					;uniquement extension video et info
					$vl_extension = ""
					$vl_val_filelist = $vl_array_filelist[$vl_i_filelist]
					if StringRight($vl_val_filelist, StringLen($vg_ini_recordacq_fichier_ext_video)) <> $vg_ini_recordacq_fichier_ext_video Then
						if StringRight($vl_val_filelist,StringLen($vg_ini_recordacq_fichier_ext_info)) <> $vg_ini_recordacq_fichier_ext_info Then
							;Erreur
							$vl_file_status = FileMove($vl_path_trt & $vl_val_filelist, $vl_path_err & $vl_val_filelist,$FC_OVERWRITE+$FC_CREATEPATH)
						Else
							$vl_extension = StringRight($vl_val_filelist,StringLen($vg_ini_recordacq_fichier_ext_info))
						EndIf
					Else
						$vl_extension = StringRight($vl_val_filelist,StringLen($vg_ini_recordacq_fichier_ext_video))
					EndIf

					;### debut traitement fichier INI
					if $vl_extension =  $vg_ini_recordacq_fichier_ext_info Then
						;Lecture fichier INI
						fChargement_ini_Information($vl_path_trt & $vl_val_filelist)

						;Déplacement du fichier info
						$vl_record_deb_time = StringLeft($vg_ini_info_s4_record_deb_time,2) & "h"
						$vl_path_dest =  $vg_ini_trt_drive & "\" & $vg_ini_trt_dossier_niv0_1  & "\" & $vg_ini_trt_dossier_niv1_1  & "\" & $vg_ini_trt_dossier_niv2_3 & "\"
						;$vl_path_dest = $vl_path_dest & StringLeft($vg_ini_info_s4_record_deb_date,7) & "\"
						;$vl_path_dest = $vl_path_dest & StringRight($vg_ini_info_s4_record_deb_date,2) & "\"
						$vl_path_dest = $vl_path_dest & $vg_ini_info_s4_record_deb_date & "\"
						$vl_path_dest = $vl_path_dest & $vl_record_deb_time
						$vl_path_dest = $vl_path_dest & "\"
						ConsoleWrite("TRT/MOVEFICHIERINFO:" & $vl_path_dest & $vl_val_filelist & @CRLF)
						$vl_file_status = FileMove($vl_path_trt & $vl_val_filelist, $vl_path_dest & $vl_val_filelist, $FC_OVERWRITE + $FC_CREATEPATH)
						$vg_pathdest_ficini = $vl_path_dest & $vl_val_filelist

						;mef path intermédiaire
						;C:\#mooviideo\#mooviideo_03_OUT\
						;20140505-20140506_CFA D YVETOT_Yvetot_76\20140505_1_Pro 1 Vitesse (1,40 m)
						;20140505_CFA D YVETOT_Yvetot_76\1_Pro 1 Vitesse (1,40 m)

						$vl_pathinter_dest = fMep_pathinter_dest(1)

						;mef path simple
						;C:\#mooviideo\#mooviideo_03_OUT\2014-06-11\22h12\
						;TODO vérifier si les heures et minutes sont correctes
						;$vl_path_dest = $vl_path_dest & StringLeft($vg_ini_info_s4_record_deb_date,7) & "\"
						;$vl_path_dest = $vl_path_dest & StringRight($vg_ini_info_s4_record_deb_date,2) & "\"
						$vl_pathinter_simple = $vg_ini_info_s4_record_deb_date & "\"
						$vl_record_deb_time = StringLeft($vg_ini_info_s4_record_deb_time,2) & "h"
						$vl_pathinter_simple = $vl_pathinter_simple & $vl_record_deb_time
						$vl_pathinter_simple = $vl_pathinter_simple & "\"


						;mef nom de fichier
						$vl_fic_dest = StringLeft($vg_ini_info_s4_record_deb_time,2) & "h" & StringMid($vg_ini_info_s4_record_deb_time,3,2) & "m" & StringMid($vg_ini_info_s4_record_deb_time,5,2) & "s"
						Switch $vg_ini_info_s8_epr_phase_code
							Case "EPR", "BAR"
								$vl_path_dest = $vl_path_dest & $vg_ini_info_s8_epr_phase & "\"
								if $vg_ini_info_s9_cav_rang = "" Then
									;cavalier non saisi
									$vl_fic_dest = $vl_fic_dest & "[rang de départ inconnu]"
								Else
									if $vg_ini_info_s9_cav_rang = "999" Then
										;cavalier/engagement terrain
										$vl_fic_dest = $vl_fic_dest & "_[engagement terrain]"
									Else
										$vl_fic_dest = $vl_fic_dest & "_" & StringFormat("%03i",$vg_ini_info_s9_cav_rang) & "_"
										if $vg_ini_info_s9_cav_nom = "" Then
											;cavalier NOK
											$vl_fic_dest = $vl_fic_dest & "[cavalier inconnu]"
										Else
											;cavalier OK
											if $vg_ini_info_s9_cav_nom = "Sous X" Then
												$vl_fic_dest = $vl_fic_dest & "[Sous X] " &  $vg_ini_info_s9_cav_cheval
											Else
												$vl_fic_dest = $vl_fic_dest & "[" & $vg_ini_info_s9_cav_prenom & " " & $vg_ini_info_s9_cav_nom & "] " & $vg_ini_info_s9_cav_cheval
											EndIf
										EndIf
									EndIf
								EndIf
							case Else
								$vl_fic_dest = $vl_fic_dest & "_[" & $vg_ini_info_s8_epr_phase & "]"
						EndSwitch
						$vl_fic_dest_ssext = $vl_fic_dest
						$vl_fic_dest = $vl_fic_dest & "." & $vg_ini_recordacq_fichier_ext_video

						;TRT selon les sections initiales du fichier INI

						;### début OUT_public_libre
						if $vg_ini_info_s1_gen_publibre = "OUI" Then
							ConsoleWrite("OUT_public_libre/" & $vl_val_filelist & @CRLF)
							$vl_path_dest = $vl_path_out_pub_libre & $vl_pathinter_dest & $vl_fic_dest_ssext & "\"
							;creation directory
							DirCreate ($vl_path_dest)
							;
							fMaj_trt_video("SNAP.PUBLIC.LIBRE", $vl_path_trt, $vg_ini_info_s4_nom_fichier_video, $vl_path_dest, "")
						EndIf

						;### début OUT_public_restreint
						if $vg_ini_info_s2_gen_pubrest = "OUI" Then
							ConsoleWrite("OUT_public_restreint/" & $vl_val_filelist & @CRLF)
							$vl_path_dest = $vl_path_out_pub_restreint & $vl_pathinter_dest & $vl_fic_dest_ssext & "\"
							;creation directory
							DirCreate ($vl_path_dest)
							;
							fMaj_trt_video("SNAP.PUBLIC.RESTREINT", $vl_path_trt, $vg_ini_info_s4_nom_fichier_video, $vl_path_dest, "")
						EndIf

						;### début OUT_vente
						if $vg_ini_info_s3_gen_vente = "OUI" Then
							ConsoleWrite("OUT_vente/" & $vl_val_filelist & @CRLF)
							$vl_path_dest = $vl_path_out_base & $vg_ini_out_dossier_niv2_2 & "\"

							switch $vg_ini_info_s3_gen_vente_type

								;### début génération SIMPLE
								case "SIMPLE"
									$vl_path_dest = $vl_path_dest & $vl_pathinter_simple
									;Copy fichier video
									ConsoleWrite("OUT_vente/COPYFICHIER:" & $vl_path_dest & $vg_ini_info_s4_nom_fichier_video & @CRLF)
									$vl_file_status = FileCopy($vl_path_trt & $vg_ini_info_s4_nom_fichier_video, $vl_path_dest & $vg_ini_info_s4_nom_fichier_video, $FC_OVERWRITE + $FC_CREATEPATH)
									;dossier DEST
									;$vl_path_dest & $vg_ini_info_s4_nom_fichier_video
								;### fin génération SIMPLE

								case "STANDARD"
									$vl_path_dest = $vl_path_dest & $vl_pathinter_dest
									;Copy fichier video
									ConsoleWrite("OUT_vente/COPYFICHIER:" & $vl_path_dest & $vg_ini_info_s4_nom_fichier_video & @CRLF)
									ConsoleWrite("OUT_vente/" & $vl_path_dest & @CRLF)
									ConsoleWrite("OUT_vente/" & $vl_fic_dest & @CRLF)
									$vl_file_status = FileCopy($vl_path_trt & $vg_ini_info_s4_nom_fichier_video, $vl_path_dest & $vl_fic_dest, $FC_OVERWRITE + $FC_CREATEPATH)
								case Else
									;idem SIMPLE
									;message erreur
							EndSwitch
						EndIf
						;### Fin OUT vente

						;OUT_web
						if $vg_ini_info_s4_gen_web = "OUI" Then
							$vl_path_dest = _ChaineSansAccents($vl_path_out_web & $vl_pathinter_dest & $vl_fic_dest_ssext & "\")
;~ 							msgbox(0,"OUT_web",$vl_pathinter_dest)
							;creation directory
							DirCreate ($vl_path_dest)
							;
;~ 							msgbox(0,"OUT_web",$vl_path_trt)
;~ 							msgbox(0,"OUT_web",$vg_ini_info_s4_nom_fichier_video)
;~ 							msgbox(0,"OUT_web",$vl_path_dest)
;~ 							msgbox(0,"OUT_web",$vl_pathinter_dest)
;~ 							msgbox(0,"OUT_web",$vl_fic_dest_ssext)

							fMaj_trt_video("IMGPRODUIT.WEB", $vl_path_trt, $vg_ini_info_s4_nom_fichier_video, $vl_path_dest, $vl_pathinter_dest & $vl_fic_dest_ssext & "\")
							fMaj_db_web($vg_ini_info_s7_con_numero)
						EndIf
						;### Fin OUT web

						;fin de traitement
						;TODO/tester le succès des COPY antérieures avant la suppression du fichier vidéo
						;suppression du fichier video
						$vl_file_status = FileDelete($vl_path_trt & $vg_ini_info_s4_nom_fichier_video)
					Endif
					;### fin traitement fichier INI
				Next
			EndIf
		EndIf
		$vl_bcl_elapse_out = 0
	EndIf


;~ 	Local $vlnMsg
;~ 	if $nMsg <> $vlnMsg Then
;~ 		ConsoleWrite("#"&$nMsg&@CRLF)
;~ 		$vlnMsg = $nMsg
;~ 	EndIf
;~ 	select
;~ 		case $nMsg = $vf_radio_conffe AND BitAND(GUICtrlRead($vf_radio_conffe), $GUI_CHECKED) = $GUI_CHECKED
;~ 			msgbox (0, '1','')
;~ 		case $nMsg = $vf_radio_conlibre And BitAND(GUICtrlRead($vf_radio_conlibre), $GUI_CHECKED) = $GUI_CHECKED
;~ 			msgbox (0, '2','')
;~ 		case $nMsg = $vf_radio_trainingstage And BitAND(GUICtrlRead($vf_radio_trainingstage), $GUI_CHECKED) = $GUI_CHECKED
;~ 			msgbox (0, '3','')
;~ 	EndSelect








	Select
	Case $nMsg = $GUI_EVENT_CLOSE
		fSauvegarde_final_INI()
		Exit

	case $nMsg = $vf_button_supr_concours


	Case $nMsg = $vf_button_hotkey
		if $vg_hotkey = 1 Then
			fHotkey("OFF")
		Else
			fHotkey("ON")
		EndIf

	case $nMsg = $vf_button_capture_ligne
		;fRang_capture(GUICtrlRead(GUICtrlRead($vf_epreuve_listview)))

	Case $nMsg = $vf_radio_ffe And BitAND(GUICtrlRead($vf_radio_ffe), $GUI_CHECKED) = $GUI_CHECKED
		$vg_type_evenement = $vg_type_eve_FFE
		fCharg_zcommun($vg_type_evenement)
		fChargement_forms_zcommun()
		fChargement_listview_epreuve($vg_type_eve_FFE)
		fRang_depart_raz()
		;ConsoleWrite("#"&$vg_type_evenement&@CRLF)

	Case $nMsg = $vf_radio_lib And BitAND(GUICtrlRead($vf_radio_lib), $GUI_CHECKED) = $GUI_CHECKED
		$vg_type_evenement = $vg_type_eve_LIB
		fCharg_zcommun($vg_type_evenement)
		fChargement_forms_zcommun()
		fChargement_listview_epreuve($vg_type_eve_LIB)
		fRang_depart_raz()
		;ConsoleWrite("#"&$vg_type_evenement&@CRLF)

	Case $nMsg = $vf_radio_trasta And BitAND(GUICtrlRead($vf_radio_trasta), $GUI_CHECKED) = $GUI_CHECKED
		$vg_type_evenement = $vg_type_eve_TRASTA
		fCharg_zcommun($vg_type_evenement)
		fChargement_forms_zcommun()
		fRang_depart_raz()
		;ConsoleWrite("#"&$vg_type_evenement&@CRLF)



		;onglet concoursFFE
	Case $nMsg = $vf_com_conffe_button_maj
			;Génération des fichiers pour la maj du siteweb
			fTrt_pageweb_ffe()
			fChargement_forms_list($vg_type_eve_FFE)
	Case $nMsg = $vf_com_conffe_button_fichierffe_traitement
			;importation du fichier concours FFE
			;ConsoleWrite("fGENER_ffedata(" & $vf_com_conffe_numero_ffe)
			fGENER_ffedata(GUICtrlRead($vf_com_conffe_numero_ffe))
			fChargement_list("FFEEPREENCOURS", "combo_epreuve_ffe.txt",1)
			fMep_infoffe()
			fCharg_zcommun($vg_type_eve_FFE)
			fChargement_forms_zcommun()
			ConsoleWrite("#/" & GUICtrlRead($vf_com_conffe_epreuveffe))
	Case $nMsg = $vf_com_conffe_button_maj_ffe
			;mep infos FFE depuis la ligne épreuve/concours en cours
			fMep_infoffe()
			$vg_type_evenement = $vg_type_eve_FFE
			fCalc_radio_evenement("SETDATA",$vg_type_eve_FFE)
			fCharg_zcommun($vg_type_eve_FFE)
			fChargement_forms_zcommun()
			fChargement_listview_epreuve($vg_type_eve_FFE)



		;onglet concoursLIBRE
	Case $nMsg = $vf_com_conlibre_traitement
			;_GUICtrlStatusBar_SetText ($StatusBar1, "test.statusbar")
			$vg_type_evenement = $vg_type_eve_LIB
			fCalc_radio_evenement("SETDATA",$vg_type_eve_LIB)
			fCharg_zcommun($vg_type_eve_LIB)
			fGENER_libredata(GUICtrlRead($vf_com_conlibre_ref))
			fChargement_listview_epreuve_libre($vg_conlib_tri)
			fChargement_forms_zcommun()
			fChargement_listview_epreuve($vg_type_eve_LIB)
	Case $nMsg = $vf_com_conlibre_button_suprdel
			;MsgBox($MB_SYSTEMMODAL, "listview item", GUICtrlRead(GUICtrlRead($vf_com_conlibre_epr_listview)), 2)
			fSUPR_libre(GUICtrlRead(GUICtrlRead($vf_com_conlibre_epr_listview)))
			fChargement_listview_epreuve_libre($vg_conlib_tri)
			fChargement_listview_epreuve($vg_type_eve_LIB)
			fCharg_zcommun($vg_type_eve_LIB)
			;http://brugbart.com/how-to-use-msgbox-autoit
	case $nMsg = $vf_com_conlibre_button_maj_libre
			if fMep_infolibre() Then
				$vg_type_evenement = $vg_type_eve_LIB
				fCalc_radio_evenement("SETDATA",$vg_type_eve_LIB)
				fCharg_zcommun($vg_type_eve_LIB)
				fChargement_forms_zcommun()
				fChargement_listview_epreuve($vg_type_eve_LIB)
			endif
	case $nMsg = $vf_com_conlib_button_tri
			;$vf_com_conlib_button_tri = GUICtrlCreateButton("Date/No", 109, 413, 60, 25)
			fConlib_tri($vg_conlib_tri)

		;Génération&Maj siteWEB
	Case $nMsg = $vf_button_maj_web
			fCharg_zcommun($vg_type_evenement)
			fExport_web_vm($vg_type_evenement,$vg_commun_numero_concours)
	Case $nMsg = $vf_button_upload_ftp
			ConsoleWrite("#uploadFTP/"&$vg_commun_numero_concours)
			fCharg_zcommun($vg_type_evenement)
			fExport_images_ftp($vg_commun_numero_concours)


		;Actions
	Case $nMsg = $vf_button_record
			fRecord()
	Case $nMsg = $vf_button_stop_save
			fSave()
	Case $nMsg = $vf_button_abort
			fAbort()
	Case $nMsg = $vf_button_raz
			fRang_depart_raz()
	Case $nMsg = $vf_button_rginc
			fRang_depart_000()
	Case $nMsg = $vf_button_engterrain
			fRang_depart_999()
	Case $nMsg = $vf_button_snapshot
			fSnapshot()
	Case $nMsg = $vf_button_1
		fRang_depart("1")
	Case $nMsg = $vf_button_2
		fRang_depart("2")
	Case $nMsg = $vf_button_3
		fRang_depart("3")
	Case $nMsg = $vf_button_4
		fRang_depart("4")
	Case $nMsg = $vf_button_5
		fRang_depart("5")
	Case $nMsg = $vf_button_6
		fRang_depart("6")
	Case $nMsg = $vf_button_7
		fRang_depart("7")
	Case $nMsg = $vf_button_8
		fRang_depart("8")
	Case $nMsg = $vf_button_9
		fRang_depart("9")
	Case $nMsg = $vf_button_0
		fRang_depart("0")
	EndSelect
WEnd
Exit

Func fRECORD_maj()
	exit
	;EQUI_machine[MOOVIIDEO-PC1]_[2013-03-03]_[202508-714]
EndFunc

