# --
# Kernel/Output/HTML/NotificationTimeAccounting.pm
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: NotificationTimeAccounting.pm,v 1.6 2009-04-03 11:49:29 tr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::NotificationTimeAccounting;

use strict;
use warnings;

use Kernel::System::TimeAccounting;
use Kernel::System::Time;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.6 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (qw(ConfigObject LogObject DBObject LayoutObject UserID)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    $Self->{TimeObject}           = Kernel::System::Time->new(%Param);
    $Self->{TimeAccountingObject} = Kernel::System::TimeAccounting->new(%Param);
    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year )
        = $Self->{TimeObject}->SystemTime2Date( SystemTime => $Self->{TimeObject}->SystemTime(), );
    my %User = $Self->{TimeAccountingObject}->UserCurrentPeriodGet(
        Year  => $Year,
        Month => $Month,
        Day   => $Day,
    );
    if ( $User{ $Self->{UserID} } ) {
        my %IncompleteWorkingDays = $Self->{TimeAccountingObject}->WorkingUnitsCompletnessCheck();

        # redirect if incomplete working day are out of range
        if ( $IncompleteWorkingDays{Warning} ) {
            return $Self->{LayoutObject}->Notify(
                Info     => 'Please insert your working hours!',
                Priority => 'Error'
            );
        }
    }
    return '';
}

1;
