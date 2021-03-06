MODULE AESDemo;

(*
 * Dies Programm zeigt die Anwendung vom Modul 'GEMBase' zum direkten
 * Zugriff auf die AES-Funktionen/Parameter.
 *
 * Die hier gezeigte Anwendung, der Aufruf der Funktion 'fsel_exinput'
 * des AES, ist sinnlos, weil sie schon in den normalen AES-Modulen
 * enthalten ist.
 *
 * Achtung: Diese Routine ist erst ab TOS 1.4 vorhanden, f�hrt bei
 * �lteren TOS-Versionen zu einer Fehlermeldung! (Sollte nicht weiter
 * schlimm sein - ist ja ein Demoprogramm)
 *
 * Sinnvoll wird dies erst bei Zugriff auf Funktionen, die vielleicht
 * in einer sp�teren GEM-Version implementiert werden und wir unsere
 * GEM-Module noch nicht adaptiert haben. Selbstverst�ndlich m�ssen Sie
 * dann selbst �ber die ben�tigten Aufrufparameter informiert sein.
 *
 * Dies Demoprogramm von Michael Seyfried erstellt und durch TT von seinem
 * AESBase/VDIBase auf GEMBase angepa�t.
 *)

FROM SYSTEM IMPORT ADR, CADR;

IMPORT MOSGlobals;

IMPORT GEMBase;

IMPORT GEMEnv;

IMPORT InOut;

VAR dev: GEMEnv.DeviceHandle;
    gemHdl: GEMEnv.GemHandle;
    path: MOSGlobals.PathStr;
    name: MOSGlobals.NameStr;
    ch: CHAR;
    ok: BOOLEAN;

PROCEDURE FselExInput(  REF title: ARRAY OF CHAR;
                        VAR path, name: ARRAY OF CHAR;
                        VAR ok: BOOLEAN);
  (*
   * Implementation von 'fsel_exinput' mit Hilfe von GEMBase.
   *)
  VAR aespb: GEMBase.AESPB; vdipb: GEMBase.VDIPB;
  BEGIN
    GEMBase.GetPBs (gemHdl, vdipb, aespb);
    WITH aespb DO
      padrin^[0]:= ADR (path);
      padrin^[1]:= ADR (name);
      padrin^[2]:= CADR (title);
      pcontrl^:= GEMBase.AESContrlArray {91, 0, 2, 3, 0};
    END;
    GEMBase.CallAES (ADR (aespb));
    ok:= (aespb.pintout^[1] = 1)
  END FselExInput;

BEGIN
  (* Zun�chst beim GEM anmelden. *)
  GEMEnv.InitGem (GEMEnv.RC, dev, ok);
  IF NOT ok THEN HALT END;
  (* GEM-Handle ermitteln *)
  gemHdl:= GEMEnv.CurrGemHandle ();

  (* Weitere Initialisierungen *)
  path:= '\*.*';
  name:= '';

  (* File-Selector aufrufen *)
  FselExInput ('Dies ist der Titel', path, name, ok);

  (* Ausgabeparameter darstellen *)
  InOut.WriteString ('path: ');
  InOut.WriteString (path);
  InOut.WriteLn;
  InOut.WriteString ('name: ');
  InOut.WriteString (name);
  InOut.WriteLn;
  IF ok THEN
    InOut.WriteString ('Es wurde der "OK"-Button angew�hlt.')
  ELSE
    InOut.WriteString ('Es wurde der "ABBRUCH"-Button angew�hlt.')
  END;
  InOut.WriteLn;
  InOut.WriteString ('Taste...');
  InOut.Read (ch)
END AESDemo.
