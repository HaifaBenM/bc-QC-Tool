page 50102 "Talan QC Package Fields API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'packageField';
    EntitySetName = 'packageFields';
    SourceTable = "Config. Package Field";
    ODataKeyFields = "Package Code", "Table ID", "Field ID";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            field(packageCode; Rec."Package Code")
            { Caption = 'packageCode', Locked = true; }
            field(tableId; Rec."Table ID")
            { Caption = 'tableId', Locked = true; }
            field(fieldId; Rec."Field ID")
            { Caption = 'fieldId', Locked = true; }
            field(fieldName; Rec."Field Name")
            { Caption = 'fieldName', Locked = true; }
            field(fieldInternalName; GetFieldInternalName())
            { Caption = 'fieldInternalName', Locked = true; }
            field(includeField; Rec."Include Field")
            { Caption = 'includeField', Locked = true; }
            field(validateField; Rec."Validate Field")
            { Caption = 'validateField', Locked = true; }
            field(refTableId; GetRelationTableId())
            { Caption = 'refTableId', Locked = true; }
            field(refFieldId; GetRelationFieldId())
            { Caption = 'refFieldId', Locked = true; }
            field(fieldType; GetFieldType())
            { Caption = 'fieldType', Locked = true; }
            field(fieldLength; GetFieldLength())
            { Caption = 'fieldLength', Locked = true; }
            field(fieldCaption; GetFieldCaption())
            { Caption = 'fieldCaption', Locked = true; }
        }
    }
    local procedure GetRelationFieldId(): Integer
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        RefRecRef: RecordRef;
        KeyRef: KeyRef;
        RelTableId: Integer;
        i: Integer;
    begin
        if Rec."Table ID" = 0 then exit(0);
        if Rec."Field ID" = 0 then exit(0);

        // Exceptions connues : la relation cible un champ précis de la table
        // référencée qui N'EST PAS le premier champ de sa clé primaire
        // (clé composée type Post Code Code+City). L'heuristique générique
        // ci-dessous ne peut pas le déterminer via réflexion AL standard.
        case true of
            (Rec."Table ID" = 23) and (Rec."Field ID" = 7): // Fournisseur.City → Post Code.City
                exit(2); // field 2 = City en standard BC (table 225)
        end;

        RecRef.Open(Rec."Table ID");
        FldRef := RecRef.Field(Rec."Field ID");
        RelTableId := FldRef.Relation();
        RecRef.Close();
        if RelTableId = 0 then exit(0);
        RefRecRef.Open(RelTableId);
        KeyRef := RefRecRef.KeyIndex(1);
        if KeyRef.FieldCount < 1 then begin
            RefRecRef.Close();
            exit(0);
        end;
        for i := 1 to KeyRef.FieldCount do begin
            if KeyRef.FieldIndex(i).Number > 0 then begin
                RefRecRef.Close();
                exit(KeyRef.FieldIndex(i).Number);
            end;
        end;
        RefRecRef.Close();
        exit(0);
    end;

    local procedure GetRelationTableId(): Integer
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Rec."Table ID" = 0 then exit(0);
        if Rec."Field ID" = 0 then exit(0);
        RecRef.Open(Rec."Table ID");
        FldRef := RecRef.Field(Rec."Field ID");
        exit(FldRef.Relation());
    end;


    local procedure GetFieldCaption(): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Rec."Table ID" = 0 then exit('');
        if Rec."Field ID" = 0 then exit('');
        GLOBALLANGUAGE(1036); // French (France)
        RecRef.Open(Rec."Table ID");
        FldRef := RecRef.Field(Rec."Field ID");
        exit(FldRef.Caption);
    end;

    local procedure GetFieldInternalName(): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Rec."Table ID" = 0 then exit('');
        if Rec."Field ID" = 0 then exit('');
        RecRef.Open(Rec."Table ID");
        FldRef := RecRef.Field(Rec."Field ID");
        exit(FldRef.Name);
    end;

    local procedure GetFieldType(): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Rec."Table ID" = 0 then exit('');
        if Rec."Field ID" = 0 then exit('');
        RecRef.Open(Rec."Table ID");
        FldRef := RecRef.Field(Rec."Field ID");
        exit(Format(FldRef.Type));
    end;

    local procedure GetFieldLength(): Integer
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Rec."Table ID" = 0 then exit(0);
        if Rec."Field ID" = 0 then exit(0);
        RecRef.Open(Rec."Table ID");
        FldRef := RecRef.Field(Rec."Field ID");
        exit(FldRef.Length);
    end;
}