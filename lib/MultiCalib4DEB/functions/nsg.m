function    nsg = significant( num )
        ddd = max( [ 1, -floor( log10( eps( num ) ) ) ] );
        frm = sprintf( '%%.%df', ddd );
        str = sprintf( frm, num );
        cac = regexp( str, '(?<=\.)\d*?(?=0*+\>)', 'match', 'emptymatch' );
        nsg = numel( cac{:} );
    end

