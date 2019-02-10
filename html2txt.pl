# html2txt.pl HTML�`���f�[�^���e�L�X�g�f�[�^��
# 1997 Sey (sey@jkc.co.jp,SDI00577@niftyserve.or.jp)
# jperl html2txt.pl HTML�t�@�C���c

# �^�O�Ƃ���ɉ����ďo�͂�����e
%out = (
"H1",	"\n\n\n\n\n",
"H2",	"\n\n\n\n",
"H3",	"\n\n\n",
"H4",	"\n\n",
"/H1",	"\n\n",
"/H2",	"\n\n",
"/H3",	"\n\n",
"/H4",	"\n\n",
"P",	"\n\n",
"HR",	"\n\n",
"BLOCKQUOTE","\n\n",
"/BLOCKQUOTE","\n\n",
"BR",	"\n",
"CENTER","\n",
"/CENTER","\n",
"DIV","\n",
"/DIV","\n",
"/HTML","\n",
"UL",	"\n",
"OL",	"\n",
"/UL",	"\n\n",
"/OL",	"\n\n",
"LI",	"\no",
"/TABLE","\n",
"TR",	"\n",
"/TD",	"\t",
"/TH",	"\t"
);

# �^�O�Ԃ̕�����̏o�͂�}������^�O
# �l�Fn �c �}���R���e�i�̊J�n c �c �V�I��  t �c ���̃^�O�܂ŗ}��
%noout = (
"COMMENT","n",
"/COMMENT","c",
"HEAD",	"n",
"/HEAD","c",
"TABLE","t",
"TR",	"t",
"/TD",	"t",
"/TR",	"t",
);

# �o�̓o�b�t�@
$outbuf = "";
# �o�͎��ɘA�������s���܂Ƃ߂邽�߂̃J�E���^
$outnl = 0;

# <PRE>���̃t���O
$pre = 0;
# �o�͗}���t���O
$noout = 0;
# ���̃^�O�܂ł̏o�͗}���t���O
$noout1tag = 0;
# ���
$status = "idle";
# ��Ɨ̈�
$buf = "";
for(;;)
    {
    # �^�O�O�̏��
    if( $status eq "idle" )
        {
        # < �����o
        if( $buf =~ /^([^<>]*)</ )
            # �����܂ł��o�͂��A< �����o������Ԃ�
            {
            $buf = $'; 
            out($1) if( !$noout && !$noout1tag ); 
            $status = "<"; 
            }
        # �݂���Ȃ�
        else
            # ���̍s��ǂ�łȂ���
            { last if( !&readline ); }
        }
    # < �����o�������
    elsif( $status eq "<" )
        {
        # <!--
        if( $buf =~ /^!--/ )
            { $buf = $'; $status = "!--"; }
        # <PRE>
        elsif( $buf =~ /^PRE */i )
            { $buf = $'; out("\n"); $pre++; $status = "wait>"; }
        # </PRE>
        elsif( $buf =~ /^\/PRE */i )
            { $buf = $'; out("\n"); $pre--; $status = "wait>"; }
        # ����ȊO�̃^�O
        elsif( $buf =~ /^[\/\?!]?[a-zA-Z0-9]+/ )
            {
            $buf = $';
            $tagname = $&;
            $tagname =~ tr/a-z/A-Z/;
            # %out�ɂ���ΑΉ�������e���o��
            if( $out{$tagname} ne "" ) {
                out($out{$tagname}) 
            }
            # �Ȃɂ��^�O��������$noout1tag�̓N���A
            $noout1tag = 0; 
            # %noout�ɂ���Ώo�͗}���t���O���Z�b�g
            # �}�����J�n����^�O
            if( $noout{$tagname} eq "n" )
                { $noout++; }
            # �}�����I������^�O
            elsif( $noout{"$tagname"} eq "c" )
                { $noout--; }
            # ���̃^�O�܂ŗ}������^�O
            elsif( $noout{$tagname} eq "t" )
                { $noout1tag = 1; }
            $status = "wait>";
            }
        # �^�O�łȂ��Ǝv����ꍇ
        else
            { out("<"); $status = "idle"; }
        }
    # �^�O���� > ��҂��
    elsif( $status eq "wait>" )
        {
        # " " �ň͂܂ꂽ������
        if( $buf =~ /^[^<>\"]*\"[^\"]*\"/ )
            { $buf = $'; }
        # > ����������
        elsif( $buf =~ /^[^<>\"]*>/ )
            { $buf = $'; $status = "idle"; }
        # �݂���Ȃ�
        else
            # ���̍s��ǂ�łȂ���
            { last if( !&readline ); }
        }
    # ���ߏ��
    elsif( $status eq "!--" )
        {
        # --> ���݂�����
        if( $buf =~ /-->/ )
            { $buf = $'; $status = "idle"; }
        # �݂���Ȃ�
        else
            # ���̍s��ǂ�łȂ���
            { last if( !&readline ); }
        }
    }
# end

# ���̍s��ǂ��$buf�ɘA��
sub readline
    {
    if( $line = <> )
        {
        # �����I���s�͂�������\x01�ɕϊ����Ă���
        $line =~ s/\n/\x01/g;
        $buf .= $line;
        1;
        }
    # �I���Ȃ�c����o�͂��ďI��
    else
        {
        out($buf) if( $status eq "idle" );
        0;
        }
    }
# end readline

# �o��
sub out
    {
    local($string) = @_;
    
    # ����L���̕ϊ�
    $string =~ s/&lt;/</g;
    $string =~ s/&gt;/>/g;
    $string =~ s/&quot;/\"/g;
    $string =~ s/&amp;/&/g;
    # <PRE>�`</PRE>���ł͕����I���s�𕜊����Ă��̂܂܏o��
    if( $pre )
        {
        $outbuf =~ s/\x01/\n/g;
        $string =~ s/\x01/\n/g;
        print $outbuf,$string;
        $outbuf = "";
        $outnl = 0;
        }
    else
        {
        # �����I���s�͏���
        $string =~ s/\x01//g;
        # �A������󔒂͂܂Ƃ߂�
        $string =~ s/ +/ /g;
        # ���s���܂ނƂ��͉��s�܂ł��o�b�t�@�ɂȂ��ďo��
        if( $string =~ /^.*\n+/ )
            {
            $string = $outbuf . $&;
            $outbuf = $';
            # �s���̋󔒂ƃ^�u�͏���
            $string =~ s/[ \t]+\n/\n/;
            # �A��������s�͂܂Ƃ߂�
            $string =~ s/\n{3,}/\n\n/;
            # ���s�݂̂̎��͑O��̉��s�����l������
            if( $string =~ /^\n+/ )
                {
                # ���ł�2��ȏ���s���Ă���΂������s���Ȃ�
                if( $outnl >= 2 )
                    { $string =~ s/^\n+//; }
                # ���Ȃ��񂾂�
                elsif( $outnl == 1 )
                    { $string =~ s/^\n+/\n/; }
                # �J�E���^�𑝂₷
                $outnl += $string =~ s/\n/\n/g;
                }
            else
                { $outnl = $string =~ s/\n/\n/g; }
            print $string;
            }
        # ���s���܂܂Ȃ����̓o�b�t�@�ɂ��߂�
        else
            { $outbuf .= $string; }
        }
    }
# end out

# end html2txt.pl
