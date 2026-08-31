// AJOUTÉ (27/08/2026) — voir Tab50109.TalanQCExcelImportReq.al pour le
// contexte complet.
//
// ⚠️⚠️⚠️ POINT CRITIQUE À VÉRIFIER AVANT TOUT DÉPLOIEMENT ⚠️⚠️⚠️
// La ligne appelant ConfigExcelExchange.ImportExcel(...) ci-dessous est
// reconstruite à partir d'un call stack public (issu d'un cas de support
// Microsoft, pas du code source lui-même) :
//   "Config. Package Card"(Page 8614)."ImportFromExcel - OnAction"
//     → "Config. Excel Exchange"(CodeUnit 8618).ImportExcelFromSelectedPackage
//       → "Config. Excel Exchange"(CodeUnit 8618).ImportExcel
// Ce call stack confirme le NOM du codeunit et de la procédure, mais PAS
// le nombre exact ni le type précis de ses paramètres — impossible à
// vérifier sans accès direct au code source du Base App (protégé,
// non lisible depuis l'extérieur de VS Code/du tenant).
//
// AVANT DE COMPILER : dans VS Code, avec l'extension AL connectée à ton
// environnement BC, fais un clic droit sur "Config. Excel Exchange" ou
// Ctrl+clic sur "ImportExcel" (une fois la ligne tapée, même si elle ne
// compile pas encore) → "Go to Definition" — ça affiche la vraie
// signature. Ajuste l'appel ci-dessous en conséquence (probablement une
// InStream + un Record "Config. Package", éventuellement un 3e paramètre
// booléen ou un nom de fichier — la doc publique ne le précise pas).
codeunit 50109 "Talan QC Excel Import Mgt"
{
    procedure ProcessImport(var ImportReq: Record "Talan QC Excel Import Req")
    var
        ConfigPackage: Record "Config. Package";
        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
        FileInStream: InStream;
    begin
        ImportReq.Success := false;
        ImportReq."Error Message" := '';

        if ImportReq."Package Code" = '' then begin
            ImportReq."Error Message" := 'Package Code manquant.';
            exit;
        end;

        if not ConfigPackage.Get(ImportReq."Package Code") then begin
            ImportReq."Error Message" := StrSubstNo('Package %1 introuvable — doit déjà exister dans BC.', ImportReq."Package Code");
            exit;
        end;

        ImportReq.CalcFields("File Content");
        if not ImportReq."File Content".HasValue then begin
            ImportReq."Error Message" := 'Aucun contenu de fichier fourni (fileContent vide).';
            exit;
        end;
        ImportReq."File Content".CreateInStream(FileInStream);

        // ⚠️ LIGNE À VÉRIFIER/AJUSTER — voir le bloc de commentaires en
        // tête de fichier avant tout déploiement.
        ConfigExcelExchange.ImportExcel(FileInStream, ConfigPackage);

        ImportReq.Success := true;
    end;
}
