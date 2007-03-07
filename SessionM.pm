##########################################################################
#
# Copyright (C) 1998-2007 Lepenkov Sergej (Serz Minus) <minus@mail333.com>
# Copyright (C) 1998-2007 D&D Corporation. All Rights Reserved
#
# Version: 2.00
# Date   : 05.03.2007
#
##########################################################################

=head1 NAME

CGI::SessionM - Module provides sessions support inside CGI-scripts.

А MySQL database is required for propertly functioning (DBI::mysql driver).

=head1 VERSION

  Version 2.00
  05.03.2007

=head1 SYNOPSIS


  #If your module SessionM.pm is located in another directory than @ISA array contains:
  #use lib 'path to your lib'; 
  use CGI::SessionM 2.00;

  -- or --

  # If your module SessionM.pm is located in another directory than @ISA array contains:
  unshift(@INC,"path to your lib");
  require CGI::SessionM;

=head2 Object $session creation

  my $session = new CGI::SessionM(
    -content=>'user data string',
    -count=>5, # maximum count of unsuccessful 
               # attempt of password entering! (0 - endless attempts)
    -forbidden=>10800, # blocking period after unsuccessful 
               # login in seconds (3 hours by default)
    -time=>1200, # session life time, in seconds after last 
               # access to a page (20 minutes by default)
    -db=>'database name',
    -login=>'database username',
    -password=>'database password',
    -host=>'database server', # is empty by default
    -table=>'tablename for working with sessions data' 
               # "sessionm" by default
  );

=head2 Authorization

First stage. Authorization

  my ($err, @authdata) = $session->authorize($login, (<$password eq '********'>), $content);

  $login - autorizing user login.
  The expression (<$password eq '********'>) returns "true" 
  if entered password is correct!
  $content - user data string.
  $err - value returned by function (return code/error). 
  See the errors description in ERRORS chapter.
  @authdata - processed data. See details in DESCRIPTION chapter.

=head2 Validation

Second stage. Session validating.

  my ($err, @authdata) = $session->validate($GUIDM);

  $GUIDM - GUIGM of session. This value passes from one 
  page to another on the site.
  $err - value returned by function (return code/error). 
  See the errors description in ERRORS chapter.
  @authdata - processed data. See details in DESCRIPTION chapter.

=head2 LOGOUT

Third stage. Session cancelling.

  my $err = $session->logout($GUIDM);

  $GUIDM - GUIGM of session. This value passes from one 
  page to another on the site.
  $err - value returned by function (return code/error). 
  See the errors description in ERRORS chapter.

=head2 Table creation

Table creation in database for working with sessions.

  my ($err, $tablename) = $session->create_table();

  Be attentive! This function is relates to DDL queries class.
  $err - value returned by function (return code/error). 
  See the errors description in ERRORS chapter.
  $tablename - name of table to create.

=head2 Userdata updating

Userdata updating.

  my $err = $session->logout($GUIDM);
  $GUIDM - GUIGM of session. This value passes from one
  page to another on the site.
  $err - value returned by function (return code/error). 
  See the errors description in ERRORS chapter.

=head2 VALUES

Getting of class property of $session object.

  print $session->echo(<key>)

  <key> - one of the enumeration: 
   maxcnt,timeout,timedie,content,guidm,login,dt,id,cnt,table

=head2 ERRORS

Getting error description.

$session->echoerr($err);

The function returns description of result's value of procedures in variable $err.

=head1 DESCRIPTION

IP-address of database server can be used as server name, e.g. 127.0.0.1. 
For non-standard port just add ";port=1234" after server name (1234 is example of port number). So the complete string will be -host=>"127.0.0.1;port=1234"

Authorize method takes "true" (non-0) and "false" (0) values as second
parameter. For "true" value session will be created without error
generation. Elsewise session will be created with error #1.
See the errors description in ERRORS chapter.

Most of methods return session data in such sequence:

=over 8

=item id

identifier of record in table

=item guidm

session identifier

=item ip

IP address

=item dt

session lifetime

=item login

user login entered for authorization

=item cnt

count of attempts to eneter password

=item content

user data

=back

You need to care for pass GUIDM value (result of authorize method) from one page to another.
It can be cookies operating or keeping GUIDM in GET/POST queries.

=head2 Simple example

my ($err,@authdata) = $session->authorize($login, $password eq 'sample' , join "||",  qw/primer dannyh polzowatelja/);

my $guidm = $authdata[1] || '';

...

my ($err,@authdata) = $session->validate($guidm);

my $guidm = $authdata[1] || '';

...

  if ($err == 0) {
     print "Set-Cookie: guidm=$guidm;\n";
  } else {
    if ($err == 1) {
      $error = session->echoerr($err)." (attempt $authdata[0] of $authdata[1])";
    } elsif($err == 4) {
      $error = session->echoerr($err)." (service is not available till $authdata[0])";
    } elsif($err == 6) {
      $error = session->echoerr($err)." \{$authdata[0]\}";
    } else {
      $error = session->echoerr($err);
    }
  }


=head2 SQL: Creation table

   CREATE TABLE sessionm (
      id INT(11) default NULL auto_increment,
      guidm char(39) default NULL,
      ip char(255) default NULL,
      dt INT(11) default NULL,
      login char(255) default NULL,
      cnt int(5) default NULL,
      content text default NULL,
      UNIQUE KEY (login),
      PRIMARY KEY (id))

=head2 ERROR description

B<0> OK (<DATA_ARRAY>) - Success. Methos returned array: <DATA_ARRAY>

B<1> PASSWORD INCORRECT (<Attemption>,<Permissible>) - Password is incorrect.  Attemption <Attemption> of permissible <Permissible>.

B<2> LOGIN INCORRECT () - Login is incorrect

B<3> GUIDM INCORRECT () - Incorrect GUIDM

B<4> FORBIDDEN (<Time>) - Access denies until <Time>

B<5> SESSION LOST () - Lost connection.

B<6> SESSION EXPIRED (<GUIDM>) - Lifetime <GUIDM> is over.

B<7> UPDATE DONE () - Userdata is updated.

B<8> TABLE CREATED (<TableName>) - Table <TableName> created.

B<9> LOGOUT DONE () - User is cancelled session

=head1 DIAGNOSTICS

The usual warnings if it cannot read or write the files involved.

=head1 HISTORY

2.00 Initial release

=head1 THANKS

Thanks to Dmitry Klimov for technical translating.

=head1 AUTHOR

Lepenkov Sergey (Serz Minus), C<minus@mail333.com>

=head1 COPYRIGHTS

Copyright (C) 1998-2007 Lepenkov Sergej (Serz Minus) C<minus@mail333.com>

Copyright (C) 1998-2007 D&D Corporation. All Rights Reserved

=cut


########################################################################## SessionM
package CGI::SessionM;
use 5.008;
$VERSION = '2.00';
use strict;

my $dbh;   # example of DataBaseConnect
my $table = "sessionm"; # Work-Table (default)

# Таблица внутренних ошибок
my @errors = (
      "OK", #0
      "PASSWORD INCORRECT", #1
      "LOGIN INCORRECT", #2
      "GUIDM INCORRECT", #3
      "FORBIDDEN", #4
      "SESSION LOST", #5
      "SESSION EXPIRED", #6
      "UPDATE DONE", #7
      "TABLE CREATED", #8
      "LOGOUT DONE" #9
  ); 


BEGIN {
  use DBI;
}


sub new {
  my $class = shift;
  my @args = @_;
  my ($content, $maxcnt, $timeout, $timedie, $base, $login, $password, $host, $table_tmp);
  
  ($content, $maxcnt, $timeout, $timedie, $base, $login, $password, $host, $table_tmp) =
  _read_attributes([
        ['DATA','CONTENT','USERDATA'],
        ['COUNT','MAXCOUNT','MAXCNT'],
        ['TIMEOUT','FORBIDDEN','INTERVAL'],
        ['TIMEDIE','TIME'],
        ['BD','DB','BASE','DATABASE'],
        ['LOGIN','USER'],
        ['PASSWORD','PASS'],
        ['HOST','HOSTNAME','ADDRESS','ADDR'],
        ['TABLE','TABLENAME','NAME','SESSION','SESSIONNAME']
  ],@args) if defined $args[0];
  
  $table = $table_tmp if $table_tmp;

  my %properties = (
        maxcnt => $maxcnt || 0,   # максимальное количество попыток! (0 - без ограничения)
        timeout => $timeout || 10800, # количество секунд действия ограничения FORBIDDEN (3 часа)
        timedie => $timedie || 1200, # количество секунд жизни сессии после залогинивания (20 минут)
        content => $content || '',
        guidm => '',
        login => '',
        dt => '',
        id => 0,
        ip => '',
        cnt => 0,
        table => $table
        # param => [@args]
  );
  
  #$dbh = DBI->connect("DBI:mysql:localhost", "root", "password");
  #my $dbih = $ENV{'REMOTE_ADDR'} eq '127.0.0.1' ?";host=192.168.4.106":'';
   
  my $dbih = '';
  $dbih = ";host=".$host if $host;
  $base = 'localhost' if $base eq '';
  my $dbis = "DBI:mysql:database=".$base.$dbih;
  my $dbil = $login || "root";
  my $dbip = $password || "";
  $dbh = DBI->connect($dbis, $dbil, $dbip) || die("Database connection error ($DBI::err) -> $DBI::errstr");
  my $self = bless {%properties}, $class; # example of object
  return $self;
}
sub create_table {
  my $self = shift;
  
  &_mysql_create_table();
  #return "TABLE CREATED (Table name: $table)";
  return (8, $table)
}

sub echo {
  my $self = shift;
  if (defined $_[0]) {
    return $self->{$_[0]};
  } else {
    return '';
  }
}
sub echoerr{
   #
   # errors
   #
   my $self = shift;
   my $indx = shift || 0;
   $errors[$indx] = "UNDEFINED ERROR #$indx: $!" unless exists $errors[$indx];
   return $errors[$indx];
}

sub authorize {
#
# Авторизация
#
my $self = shift;
my $login = shift || '';
my $predicate = shift;
my $content = shift || '';
#return "LOGIN INCORRECT" if ($login eq '');
return 2 if ($login eq '');
my @login_data = _mysql_select_login_rec($login);
if (defined $login_data[0]){
    # запись существует
    if ($predicate) {
      # пароль верен
      if ($login_data[5] >= $self->{'maxcnt'} && $self->{'maxcnt'} > 0 && ($login_data[3]+$self->{'timeout'}) > time) {
        # истекли попытки ;)
        #return "FORBIDDEN (service is not available till ".get_time($login_data[3]+$self->{'timeout'}).")";
        return (4, ($login_data[3]+$self->{'timeout'}));
      } else {
        # попытки еще есть!
        $self->_mysql_clear();
        $self->{'content'} = $content if $content;
        &_mysql_update_count($login,0,1,$self->{'content'}); # обнуление счетчика if $login_data[5] > 0
        @login_data = _mysql_select_login_rec($login);
        ($self->{'guidm'},$self->{'ip'},$self->{'dt'},$self->{'login'},$self->{'cnt'}) = @login_data[1..5];
        return (0, @login_data);
      }
    } else {
      # пароль не верен
      if (($self->{'maxcnt'} == 0) || ($login_data[5] <= $self->{'maxcnt'})) {
          # попытки еще есть!
          if ($login_data[5] >= $self->{'maxcnt'}) {
            &_mysql_update_count($login,++$login_data[5]);
            #return "FORBIDDEN (service is not available till ".get_time($login_data[3]+$self->{'timeout'}).")";
            return (4, ($login_data[3]+$self->{'timeout'}));
          }
          # инкрементируем счетчик попыток
          #return "PASSWORD INCORRECT (attempt ".&_mysql_update_count($login,++$login_data[5])." of ".($self->{'maxcnt'}).")";
          return (1, &_mysql_update_count($login,++$login_data[5]), $self->{'maxcnt'});
      } else {
          # истекли попытки ;) 
          if (($login_data[3]+$self->{'timeout'}) <= time) {
            # таймаут истек!
            # инициализировать счетчик сбросив его заначение до единицы
            #return "PASSWORD INCORRECT (attempt ".&_mysql_update_count($login,1)." of ".($self->{'maxcnt'}).")";
            return (1, &_mysql_update_count($login,1), $self->{'maxcnt'});
          } else {
            # таймаут не истек!
            #return "FORBIDDEN (service is not available till ".get_time($login_data[3]+$self->{'timeout'}).")";
            return (4, ($login_data[3]+$self->{'timeout'}));
          }
          
      }
    }
} else {
    # записи по логину нет
    $self->{'content'} = $content if $content;
    @login_data = _mysql_create_session($login,$self->{'content'});
    ($self->{'guidm'},$self->{'ip'},$self->{'dt'},$self->{'login'},$self->{'cnt'}) = @login_data[1..5];
    if ($predicate) {
      # пароль верен
      $self->_mysql_clear();
      return (0,@login_data);
    } else {
      # пароль не верен
      # инкрементируем счетчик попыток
      #return "PASSWORD INCORRECT (attempt ".&_mysql_update_count($login,++$login_data[5])." of ".($self->{'maxcnt'}).")";
      return (1, &_mysql_update_count($login,++$login_data[5]), $self->{'maxcnt'});
    }

}

}
sub validate {
#
# Получение данных сессии и выход по истечению срока ее жизни
#
my $self = shift;
my $guidm = shift || '';
#return "GUIDM INCORRECT (check is cookies accessible)" if ($guidm !~ /^[A-F0-9\-]{39}$/i);
return 3 if ($guidm !~ /^[A-F0-9\-]{39}$/i);
my @guidm_data = _mysql_select_guidm_rec($guidm);

if (defined $guidm_data[0]) {
  # данные есть в базе
  if (($guidm_data[3]+$self->{'timedie'}) > time ) {
    # Период жизни сессии не истек!
    _mysql_update_dt($guidm);
    ($self->{'guidm'},$self->{'ip'},$self->{'dt'},$self->{'login'},$self->{'cnt'}) = @guidm_data[1..5];
    return (0,@guidm_data);
  } else  {
    # Период жизни сессии истек!
    # убиваем все сессии ЛОГИНА, время жизни которых истекло
    &_mysql_delete_session($guidm);
    #return "SESSION EXPIRED \{$guidm_data[1]\}";
    return (6,$guidm_data[1]);
  }
} else {
  # данных НЕТ в базе
  #return "SESSION LOST (check is cookies accessible)";
  return 5;
}
return (0,@guidm_data);
}
sub update {
#
# Обновление пользовательских данных в базе по guidm
#
my $self = shift;
my $guidm = shift || '';
my $content = shift || '';
&_mysql_update_data($guidm,$content);
#return "UPDATE DONE";
return 7;
}
sub logout {
#
# Получение данных сессии и выход по истечению срока ее жизни
#
my $self = shift;
my $guidm = shift || '';
&_mysql_delete_session($guidm);
#return "LOGOUT DONE";
return 9;
}
sub _mysql_select_login_rec {
#
# Взятие записи по логину
#
  my $login = shift || '';
  my $sql;
  $sql="SELECT * FROM $table WHERE login=\'".&slash($login)."\'";
  my @retdata = &_MYSQL_EXECUTE_RECORD($sql);
  return @retdata;
}
sub _mysql_select_guidm_rec {
#
# Взятие записи по GUIDM
#
  my $guidm = shift || '';
  my $sql;
  $sql="SELECT * FROM $table WHERE guidm=\'".&slash($guidm)."\'";
  my @retdata = &_MYSQL_EXECUTE_RECORD($sql);
  return @retdata;
}
sub _mysql_create_table {
#
# Создание новой таблицы
#
 
  my $sql="
  CREATE TABLE $table (
     id INT(11) default NULL auto_increment,
     guidm char(39) default NULL,
     ip char(255) default NULL,
     dt INT(11) default NULL,
     login char(255) default NULL,
     cnt int(5) default NULL,
     content text default NULL,
     UNIQUE KEY (login),
     PRIMARY KEY (id))
  ";
  
  &_MYSQL_EXECUTE($sql);

}

sub _mysql_create_session {
#
# Создание новой сессии
#
# на вход:
#   - $login
#   - @data
# на выходе:
#   - все созданные поля

  my $login = shift || '';
  my $content = shift || ''; # defined $_[0]?join "\t", @_ :'';
  my $guidm = get_guidm();
  my $ip = $ENV{'REMOTE_ADDR'} || '';
  my $dt = time;
  my $cnt = 0;
  
  my $sql;
  $sql="INSERT INTO $table(guidm,ip,dt,login,cnt,content) VALUES (\'$guidm\',\'$ip\',\'$dt\',\'".&slash($login)."\',\'$cnt\',\'".&slash($content)."\')";
  my @retdata;
  if ($login ne '') {
    &_MYSQL_EXECUTE($sql);
    @retdata = _mysql_select_login_rec($login);
  }
  return @retdata;
}

sub _mysql_update_count {
#
# Обновление счетчика и временидоступа для указанного логина
#
# на вход:
#   - $login
#   - $cnt
# на выходе:
#   - $cnt

  my $login = shift || '';
  my $cnt = shift || 0;
  my $gmflag = shift || 0;
  my $content = shift || '';
  my $dt = time;
  
  
  my $sql;
  $sql="UPDATE $table SET dt=\'$dt\', cnt=\'$cnt\' ".($gmflag?(", guidm=\'".get_guidm()."\', content=\'".&slash($content)."\'"):'')." WHERE login = \'".&slash($login)."\'";
  if ($login ne '') {
    &_MYSQL_EXECUTE($sql);
  }
  #return @retdata;
  return $cnt;
}
sub _mysql_update_data {
#
# Обновление пользовательских данных сессии
#
# на вход:
#   - $guidm
#   - $content
# на выходе:
#   - $content

  my $guidm = shift || '';
  my $content = shift || '';


  my $sql;
  $sql="UPDATE $table SET content=\'".&slash($content)."\' WHERE guidm = \'".&slash($guidm)."\'";
  my @retdata;
  if ($guidm ne '') {
    &_MYSQL_EXECUTE($sql);
  }
 
  return $content;
}
sub _mysql_delete_session {
#
# Удаление указанной сессиий
#
  my $guidm = shift || '';
  my $sql;
  $sql="DELETE FROM $table WHERE guidm = '".&slash($guidm).'\'';
  # dt < '.(time - $self->{'timedie'}).' and 
  &_MYSQL_EXECUTE($sql);

}
sub _mysql_clear {
#
# Удаление сессиий, время жизни которых истекло
#
  my $self = shift;
  my $sql;
  $sql="DELETE FROM $table WHERE (cnt < ".($self->{'maxcnt'}).' and dt < '.(time - $self->{'timedie'}).') or dt < '.(time - $self->{'timeout'});
  
  # (A ang C) or B
  # A - cnt < $self->{'maxcnt'}          # счетчик в допустимых значениях
  # B - dt < (time - $self->{'timeout'}) # период запрета исчерпан (истек)
  # C - dt < (time - $self->{'timedie'}) # период времени жизни сессии истек

  &_MYSQL_EXECUTE($sql);
  return 1;
  
}
sub _mysql_update_dt {
#
# Обновление времени доступа для указанного GUIDM
#
my $guidm = shift || '';
my $dt = time;

  my $sql;
  $sql="UPDATE $table SET dt=\'$dt\' WHERE guidm = \'".&slash($guidm)."\'";
  if ($guidm ne '') {
    &_MYSQL_EXECUTE($sql);
  }
  return 1;
}
sub _MYSQL_EXECUTE_RECORD {
 my $sql = shift || '';
 my $sth = $dbh->prepare($sql) or die($dbh->errstr."<br><br>MySQL: Can't prepare query: <br><br>$sql ");
 my $rv = $sth->execute or die($dbh->errstr."<br><br>MySQL: Can't execute expression: <br><br>$sql ");
 my @result = $sth->fetchrow_array;
 return @result;
}
sub _MYSQL_EXECUTE_FIELD {
 my $sql = shift || '';
 my $sth = $dbh->prepare($sql) or die($dbh->errstr."<br><br>MySQL: Can't prepare query: <br><br>$sql ");
 my $rv = $sth->execute or die($dbh->errstr."<br><br>MySQL: Can't execute expression: <br><br>$sql ");
 my @result = $sth->fetchrow_array;
 return $result[0] || '';
}
sub _MYSQL_EXECUTE {
 my $sql = shift || '';
 my $sth = $dbh->prepare($sql) or die($dbh->errstr."<br><br>MySQL: Can't prepare query: <br><br>$sql ");
 my $rv = $sth->execute or die($dbh->errstr."<br><br>MySQL: Can't execute expression: <br><br>$sql ");
 return '';
}
sub AUTOLOAD {
    my $self = shift;
    if (defined $_[0]) {
        $self->echo(@_ );
    } else {
        $self->echo();
    }
}

DESTROY {
  $dbh->disconnect;
}

sub get_guidm {
#
# Procedure return GUIDM
#
# Example: {01BF-05E9-46F3-FF1F-B91B-6681-C3A9-15FB}
#

my $guidm = "";
my $value ='';
for (my $i=0; $i<8;$i++) {
  $value = '0000'.sprintf "%X",int(rand((2**16)-1));
  $value =~ s/^[0-9A-F]+([0-9A-F]{4})$/$1/;
  $guidm .= "-".$value;
}
$guidm=~s/^\-//;
return $guidm;
}



sub slash {
#
# Процедура удаляет системные данные из строки заменяя их 
#
my $data_staring=shift || '';

$data_staring=~s/\\/\\\\/g;
$data_staring=~s/'/\\'/g;

return $data_staring;
}
sub get_time {
 my @dt = localtime(shift || time);
 #my @months=('Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь');
 my @months=('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec');
 return ($months[$dt[4]].' '.$dt[3].', '.($dt[5]+1900).' '.$dt[2].':'.$dt[1]);
}

sub _read_attributes {
    my($order,@param) = @_;
    return () unless @param;

    if (ref($param[0]) eq 'HASH') {
	@param = %{$param[0]};
    } else {
        return @param unless (defined($param[0]) && substr($param[0],0,1) eq '-');
    }

    # map parameters into positional indices
    my ($i,%pos);
    $i = 0;
    foreach (@$order) {
	foreach (ref($_) eq 'ARRAY' ? @$_ : $_) {
            $pos{lc($_)} = $i;
        }
	$i++;
    }

    my (@result,%leftover);
    $#result = $#$order;  # preextend
    while (@param) {
	my $key = lc(shift(@param));
	$key =~ s/^\-//;
        if (exists $pos{$key}) {
	    $result[$pos{$key}] = shift(@param);
	} else {
	    $leftover{$key} = shift(@param);
	}
    }

    push (@result,_make_attributes(\%leftover,1)) if %leftover;
    @result;
}

sub _make_attributes {
    my $attr = shift;
    return () unless $attr && ref($attr) && ref($attr) eq 'HASH';
    my $escape = shift || 0;
    my(@att);
    foreach (keys %{$attr}) {
	my($key) = $_;
        $key=~s/^\-//;
	($key="\L$key") =~ tr/_/-/; # parameters are lower case, use dashes
	my $value = $escape ? $attr->{$_} : $attr->{$_};
	push(@att,defined($attr->{$_}) ? qq/$key="$value"/ : qq/$key/);
    }
    return @att;
}



1;

__END__