
{Change cursor to non-blinking underline}


  begin {program cursor}
    write (chr(26), '7')
  end   {program cursor}.
