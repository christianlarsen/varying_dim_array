**free
ctl-opt main(main) dftactgrp(*no) actgrp(*caller);

dcl-ds array_t extname('CLV1/COLOURS') qualified template;
end-ds;

dcl-proc main;
    dcl-s #a zoned(5);
    dcl-ds #arrayDS likeds(array_t) dim(*auto:1000);

    %elem(#arrayDS) = 0;

    #a = loadArrayWithFilters(#arrayDS:'NUMBER >= 4':'OR':'COLOUR LIKE ''P%''');
    if #a > 0;
        %elem(#arrayDS:*keep) = #a;
    endif;

    for #a = 1 to %elem(#arrayDS);

        snd-msg %char(#arrayDS(#a).number) + ' ' +
        #arrayDS(#a).colour;

    endfor;


end-proc;

dcl-proc loadArrayWithFilters;
    dcl-pi *n zoned(5);
        #array likeds(array_t) dim(1000) options(*varsize);
        #filter1 varchar(100) options(*nopass) const;
        #andor char(3) options(*nopass) const;
        #filter2 varchar(100) options(*nopass) const;
    end-pi;
    dcl-s #statement varchar(1000);
    dcl-s #rows int(10) inz(1000);
    dcl-s #elements zoned(5);

    #statement = 'SELECT * FROM CLV1.COLOURS';

    if %parms > 1;
        #statement = %concat(' ':#statement:'WHERE':#filter1);
    endif;
    if %parms > 2 and %parms <= 4;
        #statement = %concat(' ':#statement:#andor:#filter2);
    endif;

    exec sql
        prepare s1 from :#statement;

    exec sql
        declare c1 cursor for s1;

    exec sql
        open c1;

    exec sql
        fetch c1 for :#rows rows into :#array;

    exec sql
        get diagnostics :#elements = ROW_COUNT;

    exec sql
        close c1;

    return #elements;

end-proc;
