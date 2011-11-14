!---------------------------------------------------------------------!
!                                PHAML                                !
!                                                                     !
! The Parallel Hierarchical Adaptive MultiLevel code for solving      !
! linear elliptic partial differential equations of the form          !
! (PUx)x + (QUy)y + RU = F on 2D polygonal domains with mixed         !
! boundary conditions, and eigenvalue problems where F is lambda*U.   !
!                                                                     !
! PHAML is public domain software.  It was produced as part of work   !
! done by the U.S. Government, and is not subject to copyright in     !
! the United States.                                                  !
!                                                                     !
!     William F. Mitchell                                             !
!     Applied and Computational Mathematics Division                  !
!     National Institute of Standards and Technology                  !
!     william.mitchell@nist.gov                                       !
!     http://math.nist.gov/phaml                                      !
!                                                                     !
!---------------------------------------------------------------------!

      module sort_mod

!----------------------------------------------------
! This module contains routines for sorting vectors.  It uses the SLATEC
! routines IPSORT, SPSORT and DPSORT obtained from GAMS.
! Also provides IPPERM, SPPERM and DPPERM from GAMS.
!
! The routines have been modified to:
!    - not require XERMSG
!    - subroutine end statements have keyword subroutine
! Changes are flagged with WFM.
!
! A generic interface has been been placed on top of the routines.
!----------------------------------------------------

      interface sort
         module procedure ipsort
         module procedure spsort
         module procedure dpsort
      end interface

      interface perm
         module procedure ipperm
         module procedure spperm
         module procedure dpperm
      end interface

      contains

*DECK IPSORT
      SUBROUTINE IPSORT (IX, N, IPERM, KFLAG, IER)
C***BEGIN PROLOGUE  IPSORT
C***PURPOSE  Return the permutation vector generated by sorting a given
C            array and, optionally, rearrange the elements of the array.
C            The array may be sorted in increasing or decreasing order.
C            A slightly modified quicksort algorithm is used.
C***LIBRARY   SLATEC
C***CATEGORY  N6A1A, N6A2A
C***TYPE      INTEGER (SPSORT-S, DPSORT-D, IPSORT-I, HPSORT-H)
C***KEYWORDS  NUMBER SORTING, PASSIVE SORTING, SINGLETON QUICKSORT, SORT
C***AUTHOR  Jones, R. E., (SNLA)
C           Kahaner, D. K., (NBS)
C           Rhoads, G. S., (NBS)
C           Wisniewski, J. A., (SNLA)
C***DESCRIPTION
C
C   IPSORT returns the permutation vector IPERM generated by sorting
C   the array IX and, optionally, rearranges the values in IX.  IX may
C   be sorted in increasing or decreasing order.  A slightly modified
C   quicksort algorithm is used.
C
C   IPERM is such that IX(IPERM(I)) is the Ith value in the
C   rearrangement of IX.  IPERM may be applied to another array by
C   calling IPPERM, SPPERM, DPPERM or HPPERM.
C
C   The main difference between IPSORT and its active sorting equivalent
C   ISORT is that the data are referenced indirectly rather than
C   directly.  Therefore, IPSORT should require approximately twice as
C   long to execute as ISORT.  However, IPSORT is more general.
C
C   Description of Parameters
C      IX - input/output -- integer array of values to be sorted.
C           If ABS(KFLAG) = 2, then the values in IX will be
C           rearranged on output; otherwise, they are unchanged.
C      N  - input -- number of values in array IX to be sorted.
C      IPERM - output -- permutation array such that IPERM(I) is the
C              index of the value in the original order of the
C              IX array that is in the Ith location in the sorted
C              order.
C      KFLAG - input -- control parameter:
C            =  2  means return the permutation vector resulting from
C                  sorting IX in increasing order and sort IX also.
C            =  1  means return the permutation vector resulting from
C                  sorting IX in increasing order and do not sort IX.
C            = -1  means return the permutation vector resulting from
C                  sorting IX in decreasing order and do not sort IX.
C            = -2  means return the permutation vector resulting from
C                  sorting IX in decreasing order and sort IX also.
C      IER - output -- error indicator:
C          =  0  if no error,
C          =  1  if N is zero or negative,
C          =  2  if KFLAG is not 2, 1, -1, or -2.
C***REFERENCES  R. C. Singleton, Algorithm 347, An efficient algorithm
C                 for sorting with minimal storage, Communications of
C                 the ACM, 12, 3 (1969), pp. 185-187.
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   761101  DATE WRITTEN
C   761118  Modified by John A. Wisniewski to use the Singleton
C           quicksort algorithm.
C   810801  Further modified by David K. Kahaner.
C   870423  Modified by Gregory S. Rhoads for passive sorting with the
C           option for the rearrangement of the original data.
C   890620  Algorithm for rearranging the data vector corrected by R.
C           Boisvert.
C   890622  Prologue upgraded to Version 4.0 style by D. Lozier.
C   891128  Error when KFLAG.LT.0 and N=1 corrected by R. Boisvert.
C   920507  Modified by M. McClain to revise prologue text.
C   920818  Declarations section rebuilt and code restructured to use
C           IF-THEN-ELSE-ENDIF.  (SMR, WRB)
C***END PROLOGUE  IPSORT
C     .. Scalar Arguments ..
      INTEGER IER, KFLAG, N
C     .. Array Arguments ..
      INTEGER IPERM(*), IX(*)
C     .. Local Scalars ..
      REAL R
      INTEGER I, IJ, INDX, INDX0, ISTRT, ITEMP, J, K, KK, L, LM, LMT, M,
     +        NN
C     .. Local Arrays ..
      INTEGER IL(21), IU(21)
C     .. External Subroutines ..
c WFM      EXTERNAL XERMSG
C     .. Intrinsic Functions ..
      INTRINSIC ABS, INT
C***FIRST EXECUTABLE STATEMENT  IPSORT
      IER = 0
      NN = N
      IF (NN .LT. 1) THEN
         IER = 1
c WFM         CALL XERMSG ('SLATEC', 'IPSORT',
c WFM     +    'The number of values to be sorted, N, is not positive.',
c WFM     +    IER, 1)
         RETURN
      ENDIF
      KK = ABS(KFLAG)
      IF (KK.NE.1 .AND. KK.NE.2) THEN
         IER = 2
c WFM         CALL XERMSG ('SLATEC', 'IPSORT',
c WFM     +    'The sort control parameter, KFLAG, is not 2, 1, -1, or -2.',
c WFM     +    IER, 1)
         RETURN
      ENDIF
C
C     Initialize permutation vector
C
      DO 10 I=1,NN
         IPERM(I) = I
   10 CONTINUE
C
C     Return if only one value is to be sorted
C
      IF (NN .EQ. 1) RETURN
C
C     Alter array IX to get decreasing order if needed
C
      IF (KFLAG .LE. -1) THEN
         DO 20 I=1,NN
            IX(I) = -IX(I)
   20    CONTINUE
      ENDIF
C
C     Sort IX only
C
      M = 1
      I = 1
      J = NN
      R = .375E0
C
   30 IF (I .EQ. J) GO TO 80
      IF (R .LE. 0.5898437E0) THEN
         R = R+3.90625E-2
      ELSE
         R = R-0.21875E0
      ENDIF
C
   40 K = I
C
C     Select a central element of the array and save it in location L
C
      IJ = I + INT((J-I)*R)
      LM = IPERM(IJ)
C
C     If first element of array is greater than LM, interchange with LM
C
      IF (IX(IPERM(I)) .GT. IX(LM)) THEN
         IPERM(IJ) = IPERM(I)
         IPERM(I) = LM
         LM = IPERM(IJ)
      ENDIF
      L = J
C
C     If last element of array is less than LM, interchange with LM
C
      IF (IX(IPERM(J)) .LT. IX(LM)) THEN
         IPERM(IJ) = IPERM(J)
         IPERM(J) = LM
         LM = IPERM(IJ)
C
C        If first element of array is greater than LM, interchange
C        with LM
C
         IF (IX(IPERM(I)) .GT. IX(LM)) THEN
            IPERM(IJ) = IPERM(I)
            IPERM(I) = LM
            LM = IPERM(IJ)
         ENDIF
      ENDIF
      GO TO 60
   50 LMT = IPERM(L)
      IPERM(L) = IPERM(K)
      IPERM(K) = LMT
C
C     Find an element in the second half of the array which is smaller
C     than LM
C
   60 L = L-1
      IF (IX(IPERM(L)) .GT. IX(LM)) GO TO 60
C
C     Find an element in the first half of the array which is greater
C     than LM
C
   70 K = K+1
      IF (IX(IPERM(K)) .LT. IX(LM)) GO TO 70
C
C     Interchange these elements
C
      IF (K .LE. L) GO TO 50
C
C     Save upper and lower subscripts of the array yet to be sorted
C
      IF (L-I .GT. J-K) THEN
         IL(M) = I
         IU(M) = L
         I = K
         M = M+1
      ELSE
         IL(M) = K
         IU(M) = J
         J = L
         M = M+1
      ENDIF
      GO TO 90
C
C     Begin again on another portion of the unsorted array
C
   80 M = M-1
      IF (M .EQ. 0) GO TO 120
      I = IL(M)
      J = IU(M)
C
   90 IF (J-I .GE. 1) GO TO 40
      IF (I .EQ. 1) GO TO 30
      I = I-1
C
  100 I = I+1
      IF (I .EQ. J) GO TO 80
      LM = IPERM(I+1)
      IF (IX(IPERM(I)) .LE. IX(LM)) GO TO 100
      K = I
C
  110 IPERM(K+1) = IPERM(K)
      K = K-1
C
      IF (IX(LM) .LT. IX(IPERM(K))) GO TO 110
      IPERM(K+1) = LM
      GO TO 100
C
C     Clean up
C
  120 IF (KFLAG .LE. -1) THEN
         DO 130 I=1,NN
            IX(I) = -IX(I)
  130    CONTINUE
      ENDIF
C
C     Rearrange the values of IX if desired
C
      IF (KK .EQ. 2) THEN
C
C        Use the IPERM vector as a flag.
C        If IPERM(I) < 0, then the I-th value is in correct location
C
         DO 150 ISTRT=1,NN
            IF (IPERM(ISTRT) .GE. 0)  THEN
               INDX = ISTRT
               INDX0 = INDX
               ITEMP = IX(ISTRT)
  140          IF (IPERM(INDX) .GT. 0)  THEN
                  IX(INDX) = IX(IPERM(INDX))
                  INDX0 = INDX
                  IPERM(INDX) = -IPERM(INDX)
                  INDX = ABS(IPERM(INDX))
                  GO TO 140
               ENDIF
               IX(INDX0) = ITEMP
            ENDIF
  150    CONTINUE
C
C        Revert the signs of the IPERM values
C
         DO 160 I=1,NN
            IPERM(I) = -IPERM(I)
  160    CONTINUE
C
      ENDIF
C
      RETURN
      END SUBROUTINE ! WFM

*DECK SPSORT
      SUBROUTINE SPSORT (X, N, IPERM, KFLAG, IER)
C***BEGIN PROLOGUE  SPSORT
C***PURPOSE  Return the permutation vector generated by sorting a given
C            array and, optionally, rearrange the elements of the array.
C            The array may be sorted in increasing or decreasing order.
C            A slightly modified quicksort algorithm is used.
C***LIBRARY   SLATEC
C***CATEGORY  N6A1B, N6A2B
C***TYPE      SINGLE PRECISION (SPSORT-S, DPSORT-D, IPSORT-I, HPSORT-H)
C***KEYWORDS  NUMBER SORTING, PASSIVE SORTING, SINGLETON QUICKSORT, SORT
C***AUTHOR  Jones, R. E., (SNLA)
C           Rhoads, G. S., (NBS)
C           Wisniewski, J. A., (SNLA)
C***DESCRIPTION
C
C   SPSORT returns the permutation vector IPERM generated by sorting
C   the array X and, optionally, rearranges the values in X.  X may
C   be sorted in increasing or decreasing order.  A slightly modified
C   quicksort algorithm is used.
C
C   IPERM is such that X(IPERM(I)) is the Ith value in the rearrangement
C   of X.  IPERM may be applied to another array by calling IPPERM,
C   SPPERM, DPPERM or HPPERM.
C
C   The main difference between SPSORT and its active sorting equivalent
C   SSORT is that the data are referenced indirectly rather than
C   directly.  Therefore, SPSORT should require approximately twice as
C   long to execute as SSORT.  However, SPSORT is more general.
C
C   Description of Parameters
C      X - input/output -- real array of values to be sorted.
C          If ABS(KFLAG) = 2, then the values in X will be
C          rearranged on output; otherwise, they are unchanged.
C      N - input -- number of values in array X to be sorted.
C      IPERM - output -- permutation array such that IPERM(I) is the
C              index of the value in the original order of the
C              X array that is in the Ith location in the sorted
C              order.
C      KFLAG - input -- control parameter:
C            =  2  means return the permutation vector resulting from
C                  sorting X in increasing order and sort X also.
C            =  1  means return the permutation vector resulting from
C                  sorting X in increasing order and do not sort X.
C            = -1  means return the permutation vector resulting from
C                  sorting X in decreasing order and do not sort X.
C            = -2  means return the permutation vector resulting from
C                  sorting X in decreasing order and sort X also.
C      IER - output -- error indicator:
C          =  0  if no error,
C          =  1  if N is zero or negative,
C          =  2  if KFLAG is not 2, 1, -1, or -2.
C***REFERENCES  R. C. Singleton, Algorithm 347, An efficient algorithm
C                 for sorting with minimal storage, Communications of
C                 the ACM, 12, 3 (1969), pp. 185-187.
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   761101  DATE WRITTEN
C   761118  Modified by John A. Wisniewski to use the Singleton
C           quicksort algorithm.
C   870423  Modified by Gregory S. Rhoads for passive sorting with the
C           option for the rearrangement of the original data.
C   890620  Algorithm for rearranging the data vector corrected by R.
C           Boisvert.
C   890622  Prologue upgraded to Version 4.0 style by D. Lozier.
C   891128  Error when KFLAG.LT.0 and N=1 corrected by R. Boisvert.
C   920507  Modified by M. McClain to revise prologue text.
C   920818  Declarations section rebuilt and code restructured to use
C           IF-THEN-ELSE-ENDIF.  (SMR, WRB)
C***END PROLOGUE  SPSORT
C     .. Scalar Arguments ..
      INTEGER IER, KFLAG, N
C     .. Array Arguments ..
      REAL X(*)
      INTEGER IPERM(*)
C     .. Local Scalars ..
      REAL R, TEMP
      INTEGER I, IJ, INDX, INDX0, ISTRT, J, K, KK, L, LM, LMT, M, NN
C     .. Local Arrays ..
      INTEGER IL(21), IU(21)
C     .. External Subroutines ..
c WFM      EXTERNAL XERMSG
C     .. Intrinsic Functions ..
      INTRINSIC ABS, INT
C***FIRST EXECUTABLE STATEMENT  SPSORT
      IER = 0
      NN = N
      IF (NN .LT. 1) THEN
         IER = 1
c WFM         CALL XERMSG ('SLATEC', 'SPSORT',
c WFM     +    'The number of values to be sorted, N, is not positive.',
c WFM     +    IER, 1)
         RETURN
      ENDIF
      KK = ABS(KFLAG)
      IF (KK.NE.1 .AND. KK.NE.2) THEN
         IER = 2
c WFM         CALL XERMSG ('SLATEC', 'SPSORT',
c WFM     +    'The sort control parameter, KFLAG, is not 2, 1, -1, or -2.',
c WFM     +    IER, 1)
         RETURN
      ENDIF
C
C     Initialize permutation vector
C
      DO 10 I=1,NN
         IPERM(I) = I
   10 CONTINUE
C
C     Return if only one value is to be sorted
C
      IF (NN .EQ. 1) RETURN
C
C     Alter array X to get decreasing order if needed
C
      IF (KFLAG .LE. -1) THEN
         DO 20 I=1,NN
            X(I) = -X(I)
   20    CONTINUE
      ENDIF
C
C     Sort X only
C
      M = 1
      I = 1
      J = NN
      R = .375E0
C
   30 IF (I .EQ. J) GO TO 80
      IF (R .LE. 0.5898437E0) THEN
         R = R+3.90625E-2
      ELSE
         R = R-0.21875E0
      ENDIF
C
   40 K = I
C
C     Select a central element of the array and save it in location L
C
      IJ = I + INT((J-I)*R)
      LM = IPERM(IJ)
C
C     If first element of array is greater than LM, interchange with LM
C
      IF (X(IPERM(I)) .GT. X(LM)) THEN
         IPERM(IJ) = IPERM(I)
         IPERM(I) = LM
         LM = IPERM(IJ)
      ENDIF
      L = J
C
C     If last element of array is less than LM, interchange with LM
C
      IF (X(IPERM(J)) .LT. X(LM)) THEN
         IPERM(IJ) = IPERM(J)
         IPERM(J) = LM
         LM = IPERM(IJ)
C
C        If first element of array is greater than LM, interchange
C        with LM
C
         IF (X(IPERM(I)) .GT. X(LM)) THEN
            IPERM(IJ) = IPERM(I)
            IPERM(I) = LM
            LM = IPERM(IJ)
         ENDIF
      ENDIF
      GO TO 60
   50 LMT = IPERM(L)
      IPERM(L) = IPERM(K)
      IPERM(K) = LMT
C
C     Find an element in the second half of the array which is smaller
C     than LM
C
   60 L = L-1
      IF (X(IPERM(L)) .GT. X(LM)) GO TO 60
C
C     Find an element in the first half of the array which is greater
C     than LM
C
   70 K = K+1
      IF (X(IPERM(K)) .LT. X(LM)) GO TO 70
C
C     Interchange these elements
C
      IF (K .LE. L) GO TO 50
C
C     Save upper and lower subscripts of the array yet to be sorted
C
      IF (L-I .GT. J-K) THEN
         IL(M) = I
         IU(M) = L
         I = K
         M = M+1
      ELSE
         IL(M) = K
         IU(M) = J
         J = L
         M = M+1
      ENDIF
      GO TO 90
C
C     Begin again on another portion of the unsorted array
C
   80 M = M-1
      IF (M .EQ. 0) GO TO 120
      I = IL(M)
      J = IU(M)
C
   90 IF (J-I .GE. 1) GO TO 40
      IF (I .EQ. 1) GO TO 30
      I = I-1
C
  100 I = I+1
      IF (I .EQ. J) GO TO 80
      LM = IPERM(I+1)
      IF (X(IPERM(I)) .LE. X(LM)) GO TO 100
      K = I
C
  110 IPERM(K+1) = IPERM(K)
      K = K-1
C
      IF (X(LM) .LT. X(IPERM(K))) GO TO 110
      IPERM(K+1) = LM
      GO TO 100
C
C     Clean up
C
  120 IF (KFLAG .LE. -1) THEN
         DO 130 I=1,NN
            X(I) = -X(I)
  130    CONTINUE
      ENDIF
C
C     Rearrange the values of X if desired
C
      IF (KK .EQ. 2) THEN
C
C        Use the IPERM vector as a flag.
C        If IPERM(I) < 0, then the I-th value is in correct location
C
         DO 150 ISTRT=1,NN
            IF (IPERM(ISTRT) .GE. 0) THEN
               INDX = ISTRT
               INDX0 = INDX
               TEMP = X(ISTRT)
  140          IF (IPERM(INDX) .GT. 0) THEN
                  X(INDX) = X(IPERM(INDX))
                  INDX0 = INDX
                  IPERM(INDX) = -IPERM(INDX)
                  INDX = ABS(IPERM(INDX))
                  GO TO 140
               ENDIF
               X(INDX0) = TEMP
            ENDIF
  150    CONTINUE
C
C        Revert the signs of the IPERM values
C
         DO 160 I=1,NN
            IPERM(I) = -IPERM(I)
  160    CONTINUE
C
      ENDIF
C
      RETURN
      END SUBROUTINE ! WFM

*DECK DPSORT
      SUBROUTINE DPSORT (DX, N, IPERM, KFLAG, IER)
C***BEGIN PROLOGUE  DPSORT
C***PURPOSE  Return the permutation vector generated by sorting a given
C            array and, optionally, rearrange the elements of the array.
C            The array may be sorted in increasing or decreasing order.
C            A slightly modified quicksort algorithm is used.
C***LIBRARY   SLATEC
C***CATEGORY  N6A1B, N6A2B
C***TYPE      DOUBLE PRECISION (SPSORT-S, DPSORT-D, IPSORT-I, HPSORT-H)
C***KEYWORDS  NUMBER SORTING, PASSIVE SORTING, SINGLETON QUICKSORT, SORT
C***AUTHOR  Jones, R. E., (SNLA)
C           Rhoads, G. S., (NBS)
C           Wisniewski, J. A., (SNLA)
C***DESCRIPTION
C
C   DPSORT returns the permutation vector IPERM generated by sorting
C   the array DX and, optionally, rearranges the values in DX.  DX may
C   be sorted in increasing or decreasing order.  A slightly modified
C   quicksort algorithm is used.
C
C   IPERM is such that DX(IPERM(I)) is the Ith value in the
C   rearrangement of DX.  IPERM may be applied to another array by
C   calling IPPERM, SPPERM, DPPERM or HPPERM.
C
C   The main difference between DPSORT and its active sorting equivalent
C   DSORT is that the data are referenced indirectly rather than
C   directly.  Therefore, DPSORT should require approximately twice as
C   long to execute as DSORT.  However, DPSORT is more general.
C
C   Description of Parameters
C      DX - input/output -- double precision array of values to be
C           sorted.  If ABS(KFLAG) = 2, then the values in DX will be
C           rearranged on output; otherwise, they are unchanged.
C      N  - input -- number of values in array DX to be sorted.
C      IPERM - output -- permutation array such that IPERM(I) is the
C              index of the value in the original order of the
C              DX array that is in the Ith location in the sorted
C              order.
C      KFLAG - input -- control parameter:
C            =  2  means return the permutation vector resulting from
C                  sorting DX in increasing order and sort DX also.
C            =  1  means return the permutation vector resulting from
C                  sorting DX in increasing order and do not sort DX.
C            = -1  means return the permutation vector resulting from
C                  sorting DX in decreasing order and do not sort DX.
C            = -2  means return the permutation vector resulting from
C                  sorting DX in decreasing order and sort DX also.
C      IER - output -- error indicator:
C          =  0  if no error,
C          =  1  if N is zero or negative,
C          =  2  if KFLAG is not 2, 1, -1, or -2.
C***REFERENCES  R. C. Singleton, Algorithm 347, An efficient algorithm
C                 for sorting with minimal storage, Communications of
C                 the ACM, 12, 3 (1969), pp. 185-187.
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   761101  DATE WRITTEN
C   761118  Modified by John A. Wisniewski to use the Singleton
C           quicksort algorithm.
C   870423  Modified by Gregory S. Rhoads for passive sorting with the
C           option for the rearrangement of the original data.
C   890619  Double precision version of SPSORT created by D. W. Lozier.
C   890620  Algorithm for rearranging the data vector corrected by R.
C           Boisvert.
C   890622  Prologue upgraded to Version 4.0 style by D. Lozier.
C   891128  Error when KFLAG.LT.0 and N=1 corrected by R. Boisvert.
C   920507  Modified by M. McClain to revise prologue text.
C   920818  Declarations section rebuilt and code restructured to use
C           IF-THEN-ELSE-ENDIF.  (SMR, WRB)
C***END PROLOGUE  DPSORT
C     .. Scalar Arguments ..
      INTEGER IER, KFLAG, N
C     .. Array Arguments ..
      DOUBLE PRECISION DX(*)
      INTEGER IPERM(*)
C     .. Local Scalars ..
      DOUBLE PRECISION R, TEMP
      INTEGER I, IJ, INDX, INDX0, ISTRT, J, K, KK, L, LM, LMT, M, NN
C     .. Local Arrays ..
      INTEGER IL(21), IU(21)
C     .. External Subroutines ..
c WFM      EXTERNAL XERMSG
C     .. Intrinsic Functions ..
      INTRINSIC ABS, INT
C***FIRST EXECUTABLE STATEMENT  DPSORT
      IER = 0
      NN = N
      IF (NN .LT. 1) THEN
         IER = 1
c WFM         CALL XERMSG ('SLATEC', 'DPSORT',
c WFM     +    'The number of values to be sorted, N, is not positive.',
c WFM     +    IER, 1)
         RETURN
      ENDIF
C
      KK = ABS(KFLAG)
      IF (KK.NE.1 .AND. KK.NE.2) THEN
         IER = 2
c WFM         CALL XERMSG ('SLATEC', 'DPSORT',
c WFM     +    'The sort control parameter, KFLAG, is not 2, 1, -1, or -2.',
c WFM     +    IER, 1)
         RETURN
      ENDIF
C
C     Initialize permutation vector
C
      DO 10 I=1,NN
         IPERM(I) = I
   10 CONTINUE
C
C     Return if only one value is to be sorted
C
      IF (NN .EQ. 1) RETURN
C
C     Alter array DX to get decreasing order if needed
C
      IF (KFLAG .LE. -1) THEN
         DO 20 I=1,NN
            DX(I) = -DX(I)
   20    CONTINUE
      ENDIF
C
C     Sort DX only
C
      M = 1
      I = 1
      J = NN
      R = .375D0
C
   30 IF (I .EQ. J) GO TO 80
      IF (R .LE. 0.5898437D0) THEN
         R = R+3.90625D-2
      ELSE
         R = R-0.21875D0
      ENDIF
C
   40 K = I
C
C     Select a central element of the array and save it in location L
C
      IJ = I + INT((J-I)*R)
      LM = IPERM(IJ)
C
C     If first element of array is greater than LM, interchange with LM
C
      IF (DX(IPERM(I)) .GT. DX(LM)) THEN
         IPERM(IJ) = IPERM(I)
         IPERM(I) = LM
         LM = IPERM(IJ)
      ENDIF
      L = J
C
C     If last element of array is less than LM, interchange with LM
C
      IF (DX(IPERM(J)) .LT. DX(LM)) THEN
         IPERM(IJ) = IPERM(J)
         IPERM(J) = LM
         LM = IPERM(IJ)
C
C        If first element of array is greater than LM, interchange
C        with LM
C
         IF (DX(IPERM(I)) .GT. DX(LM)) THEN
            IPERM(IJ) = IPERM(I)
            IPERM(I) = LM
            LM = IPERM(IJ)
         ENDIF
      ENDIF
      GO TO 60
   50 LMT = IPERM(L)
      IPERM(L) = IPERM(K)
      IPERM(K) = LMT
C
C     Find an element in the second half of the array which is smaller
C     than LM
C
   60 L = L-1
      IF (DX(IPERM(L)) .GT. DX(LM)) GO TO 60
C
C     Find an element in the first half of the array which is greater
C     than LM
C
   70 K = K+1
      IF (DX(IPERM(K)) .LT. DX(LM)) GO TO 70
C
C     Interchange these elements
C
      IF (K .LE. L) GO TO 50
C
C     Save upper and lower subscripts of the array yet to be sorted
C
      IF (L-I .GT. J-K) THEN
         IL(M) = I
         IU(M) = L
         I = K
         M = M+1
      ELSE
         IL(M) = K
         IU(M) = J
         J = L
         M = M+1
      ENDIF
      GO TO 90
C
C     Begin again on another portion of the unsorted array
C
   80 M = M-1
      IF (M .EQ. 0) GO TO 120
      I = IL(M)
      J = IU(M)
C
   90 IF (J-I .GE. 1) GO TO 40
      IF (I .EQ. 1) GO TO 30
      I = I-1
C
  100 I = I+1
      IF (I .EQ. J) GO TO 80
      LM = IPERM(I+1)
      IF (DX(IPERM(I)) .LE. DX(LM)) GO TO 100
      K = I
C
  110 IPERM(K+1) = IPERM(K)
      K = K-1
      IF (DX(LM) .LT. DX(IPERM(K))) GO TO 110
      IPERM(K+1) = LM
      GO TO 100
C
C     Clean up
C
  120 IF (KFLAG .LE. -1) THEN
         DO 130 I=1,NN
            DX(I) = -DX(I)
  130    CONTINUE
      ENDIF
C
C     Rearrange the values of DX if desired
C
      IF (KK .EQ. 2) THEN
C
C        Use the IPERM vector as a flag.
C        If IPERM(I) < 0, then the I-th value is in correct location
C
         DO 150 ISTRT=1,NN
            IF (IPERM(ISTRT) .GE. 0) THEN
               INDX = ISTRT
               INDX0 = INDX
               TEMP = DX(ISTRT)
  140          IF (IPERM(INDX) .GT. 0) THEN
                  DX(INDX) = DX(IPERM(INDX))
                  INDX0 = INDX
                  IPERM(INDX) = -IPERM(INDX)
                  INDX = ABS(IPERM(INDX))
                  GO TO 140
               ENDIF
               DX(INDX0) = TEMP
            ENDIF
  150    CONTINUE
C
C        Revert the signs of the IPERM values
C
         DO 160 I=1,NN
            IPERM(I) = -IPERM(I)
  160    CONTINUE
C
      ENDIF
C
      RETURN
      END SUBROUTINE ! WFM

*DECK IPPERM
      SUBROUTINE IPPERM (IX, N, IPERM, IER)
C***BEGIN PROLOGUE  IPPERM
C***PURPOSE  Rearrange a given array according to a prescribed
C            permutation vector.
C***LIBRARY   SLATEC
C***CATEGORY  N8
C***TYPE      INTEGER (SPPERM-S, DPPERM-D, IPPERM-I, HPPERM-H)
C***KEYWORDS  APPLICATION OF PERMUTATION TO DATA VECTOR
C***AUTHOR  McClain, M. A., (NIST)
C           Rhoads, G. S., (NBS)
C***DESCRIPTION
C
C         IPPERM rearranges the data vector IX according to the
C         permutation IPERM: IX(I) <--- IX(IPERM(I)).  IPERM could come
C         from one of the sorting routines IPSORT, SPSORT, DPSORT or
C         HPSORT.
C
C     Description of Parameters
C         IX - input/output -- integer array of values to be rearranged.
C         N - input -- number of values in integer array IX.
C         IPERM - input -- permutation vector.
C         IER - output -- error indicator:
C             =  0  if no error,
C             =  1  if N is zero or negative,
C             =  2  if IPERM is not a valid permutation.
C
C***REFERENCES  (NONE)
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   900618  DATE WRITTEN
C   920507  Modified by M. McClain to revise prologue text.
C***END PROLOGUE  IPPERM
      INTEGER IX(*), N, IPERM(*), I, IER, INDX, INDX0, ITEMP, ISTRT
C***FIRST EXECUTABLE STATEMENT  IPPERM
      IER=0
      IF(N.LT.1)THEN
         IER=1
C WFM         CALL XERMSG ('SLATEC', 'IPPERM',
C WFM     +    'The number of values to be rearranged, N, is not positive.',
C WFM     +    IER, 1)
         RETURN
      ENDIF
C
C     CHECK WHETHER IPERM IS A VALID PERMUTATION
C
      DO 100 I=1,N
         INDX=ABS(IPERM(I))
         IF((INDX.GE.1).AND.(INDX.LE.N))THEN
            IF(IPERM(INDX).GT.0)THEN
               IPERM(INDX)=-IPERM(INDX)
               GOTO 100
            ENDIF
         ENDIF
         IER=2
C WFM         CALL XERMSG ('SLATEC', 'IPPERM',
C WFM     +    'The permutation vector, IPERM, is not valid.', IER, 1)
         RETURN
  100 CONTINUE
C
C     REARRANGE THE VALUES OF IX
C
C     USE THE IPERM VECTOR AS A FLAG.
C     IF IPERM(I) > 0, THEN THE I-TH VALUE IS IN CORRECT LOCATION
C
      DO 330 ISTRT = 1 , N
         IF (IPERM(ISTRT) .GT. 0) GOTO 330
         INDX = ISTRT
         INDX0 = INDX
         ITEMP = IX(ISTRT)
  320    CONTINUE
         IF (IPERM(INDX) .GE. 0) GOTO 325
            IX(INDX) = IX(-IPERM(INDX))
            INDX0 = INDX
            IPERM(INDX) = -IPERM(INDX)
            INDX = IPERM(INDX)
            GOTO 320
  325    CONTINUE
         IX(INDX0) = ITEMP
  330 CONTINUE
C
      RETURN
      END SUBROUTINE ! WFM

*DECK DPPERM
      SUBROUTINE DPPERM (DX, N, IPERM, IER)
C***BEGIN PROLOGUE  DPPERM
C***PURPOSE  Rearrange a given array according to a prescribed
C            permutation vector.
C***LIBRARY   SLATEC
C***CATEGORY  N8
C***TYPE      DOUBLE PRECISION (SPPERM-S, DPPERM-D, IPPERM-I, HPPERM-H)
C***KEYWORDS  PERMUTATION, REARRANGEMENT
C***AUTHOR  McClain, M. A., (NIST)
C           Rhoads, G. S., (NBS)
C***DESCRIPTION
C
C         DPPERM rearranges the data vector DX according to the
C         permutation IPERM: DX(I) <--- DX(IPERM(I)).  IPERM could come
C         from one of the sorting routines IPSORT, SPSORT, DPSORT or
C         HPSORT.
C
C     Description of Parameters
C         DX - input/output -- double precision array of values to be
C                   rearranged.
C         N - input -- number of values in double precision array DX.
C         IPERM - input -- permutation vector.
C         IER - output -- error indicator:
C             =  0  if no error,
C             =  1  if N is zero or negative,
C             =  2  if IPERM is not a valid permutation.
C
C***REFERENCES  (NONE)
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   901004  DATE WRITTEN
C   920507  Modified by M. McClain to revise prologue text.
C***END PROLOGUE  DPPERM
      INTEGER N, IPERM(*), I, IER, INDX, INDX0, ISTRT
      DOUBLE PRECISION DX(*), DTEMP
C***FIRST EXECUTABLE STATEMENT  DPPERM
      IER=0
      IF(N.LT.1)THEN
         IER=1
C WFM         CALL XERMSG ('SLATEC', 'DPPERM',
C WFM     +    'The number of values to be rearranged, N, is not positive.',
C WFM     +    IER, 1)
         RETURN
      ENDIF
C
C     CHECK WHETHER IPERM IS A VALID PERMUTATION
C
      DO 100 I=1,N
         INDX=ABS(IPERM(I))
         IF((INDX.GE.1).AND.(INDX.LE.N))THEN
            IF(IPERM(INDX).GT.0)THEN
               IPERM(INDX)=-IPERM(INDX)
               GOTO 100
            ENDIF
         ENDIF
         IER=2
C WFM         CALL XERMSG ('SLATEC', 'DPPERM',
C WFM     +    'The permutation vector, IPERM, is not valid.', IER, 1)
         RETURN
  100 CONTINUE
C
C     REARRANGE THE VALUES OF DX
C
C     USE THE IPERM VECTOR AS A FLAG.
C     IF IPERM(I) > 0, THEN THE I-TH VALUE IS IN CORRECT LOCATION
C
      DO 330 ISTRT = 1 , N
         IF (IPERM(ISTRT) .GT. 0) GOTO 330
         INDX = ISTRT
         INDX0 = INDX
         DTEMP = DX(ISTRT)
  320    CONTINUE
         IF (IPERM(INDX) .GE. 0) GOTO 325
            DX(INDX) = DX(-IPERM(INDX))
            INDX0 = INDX
            IPERM(INDX) = -IPERM(INDX)
            INDX = IPERM(INDX)
            GOTO 320
  325    CONTINUE
         DX(INDX0) = DTEMP
  330 CONTINUE
C
      RETURN
      END SUBROUTINE ! WFM

*DECK SPPERM
      SUBROUTINE SPPERM (X, N, IPERM, IER)
C***BEGIN PROLOGUE  SPPERM
C***PURPOSE  Rearrange a given array according to a prescribed
C            permutation vector.
C***LIBRARY   SLATEC
C***CATEGORY  N8
C***TYPE      SINGLE PRECISION (SPPERM-S, DPPERM-D, IPPERM-I, HPPERM-H)
C***KEYWORDS  APPLICATION OF PERMUTATION TO DATA VECTOR
C***AUTHOR  McClain, M. A., (NIST)
C           Rhoads, G. S., (NBS)
C***DESCRIPTION
C
C         SPPERM rearranges the data vector X according to the
C         permutation IPERM: X(I) <--- X(IPERM(I)).  IPERM could come
C         from one of the sorting routines IPSORT, SPSORT, DPSORT or
C         HPSORT.
C
C     Description of Parameters
C         X - input/output -- real array of values to be rearranged.
C         N - input -- number of values in real array X.
C         IPERM - input -- permutation vector.
C         IER - output -- error indicator:
C             =  0  if no error,
C             =  1  if N is zero or negative,
C             =  2  if IPERM is not a valid permutation.
C
C***REFERENCES  (NONE)
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   901004  DATE WRITTEN
C   920507  Modified by M. McClain to revise prologue text.
C***END PROLOGUE  SPPERM
      INTEGER N, IPERM(*), I, IER, INDX, INDX0, ISTRT
      REAL X(*), TEMP
C***FIRST EXECUTABLE STATEMENT  SPPERM
      IER=0
      IF(N.LT.1)THEN
         IER=1
C WFM         CALL XERMSG ('SLATEC', 'SPPERM',
C WFM     +    'The number of values to be rearranged, N, is not positive.',
C WFM     +    IER, 1)
         RETURN
      ENDIF
C
C     CHECK WHETHER IPERM IS A VALID PERMUTATION
C
      DO 100 I=1,N
         INDX=ABS(IPERM(I))
         IF((INDX.GE.1).AND.(INDX.LE.N))THEN
            IF(IPERM(INDX).GT.0)THEN
               IPERM(INDX)=-IPERM(INDX)
               GOTO 100
            ENDIF
         ENDIF
         IER=2
C WFM         CALL XERMSG ('SLATEC', 'SPPERM',
C WFM     +    'The permutation vector, IPERM, is not valid.', IER, 1)
         RETURN
  100 CONTINUE
C
C     REARRANGE THE VALUES OF X
C
C     USE THE IPERM VECTOR AS A FLAG.
C     IF IPERM(I) > 0, THEN THE I-TH VALUE IS IN CORRECT LOCATION
C
      DO 330 ISTRT = 1 , N
         IF (IPERM(ISTRT) .GT. 0) GOTO 330
         INDX = ISTRT
         INDX0 = INDX
         TEMP = X(ISTRT)
  320    CONTINUE
         IF (IPERM(INDX) .GE. 0) GOTO 325
            X(INDX) = X(-IPERM(INDX))
            INDX0 = INDX
            IPERM(INDX) = -IPERM(INDX)
            INDX = IPERM(INDX)
            GOTO 320
  325    CONTINUE
         X(INDX0) = TEMP
  330 CONTINUE
C
      RETURN
      END SUBROUTINE ! WFM

      end module sort_mod
