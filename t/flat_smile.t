#!/usr/bin/perl

use Test::Deep;
use Test::More;
use Test::FailWarnings;

use Finance::Underlying;

subtest 'flat_smile' => sub {
    my $expected = [
        'frxBROUSD',   'frxXPTAUD',   'frxBROGBP',   'frxXPDAUD',   'frxBROEUR',  'frxBROAUD',   'frxEURAED',   'frxGBPAED',
        'frxCADJPY',   'frxUSDAED',   'frxAUDTRY',   'frxEURTRY',   'frxNZDCHF',  'frxGBPTRY',   'frxCADCHF',   'frxCHFJPY',
        'frxAUDAED',   'frxUSDIQD',   'frxUSDISK',   'frxUSDAFN',   'frxUSDAOA',  'frxUSDALL',   'frxUSDAMD',   'frxUSDAZM',
        'frxUSDAWG',   'frxUSDBMD',   'frxUSDERN',   'frxUSDKYD',   'frxUSDBZD',  'frxUSDBSD',   'frxUSDARS',   'frxUSDBAM',
        'frxUSDBBD',   'frxUSDBDT',   'frxUSDBHD',   'frxUSDBIF',   'frxUSDBOB',  'frxUSDBND',   'frxUSDBRL',   'frxUSDBTN',
        'frxUSDBWP',   'frxUSDBYR',   'frxUSDCDF',   'frxUSDCLP',   'frxUSDCNY',  'frxUSDCOP',   'frxUSDCRC',   'frxUSDCUP',
        'frxUSDCVE',   'frxUSDDKK',   'frxUSDDJF',   'frxUSDDOP',   'frxUSDDZD',  'frxUSDECS',   'frxUSDEGP',   'frxUSDETB',
        'frxFKPUSD',   'frxUSDFJD',   'frxUSDGEL',   'frxUSDGMD',   'frxUSDGNF',  'frxUSDGQE',   'frxGIPUSD',   'frxUSDGHC',
        'frxUSDGTQ',   'frxUSDGYD',   'frxUSDHNL',   'frxUSDHTG',   'frxUSDJMD',  'frxUSDJOD',   'frxUSDKES',   'frxUSDKGS',
        'frxUSDKHR',   'frxUSDKMF',   'frxUSDKRW',   'frxUSDKWD',   'frxUSDKZT',  'frxUSDLAK',   'frxUSDLBP',   'frxUSDLKR',
        'frxUSDLRD',   'frxUSDLSL',   'frxUSDLYD',   'frxUSDMAD',   'frxUSDMDL',  'frxUSDMGA',   'frxUSDMGF',   'frxUSDMKD',
        'frxUSDMMK',   'frxUSDMOP',   'frxUSDMNT',   'frxUSDMUR',   'frxUSDMVR',  'frxUSDMWK',   'frxUSDMZM',   'frxUSDNAD',
        'frxUSDNGN',   'frxUSDNIO',   'frxUSDNPR',   'frxUSDOMR',   'frxUSDPAB',  'frxUSDPEN',   'frxUSDPHP',   'frxUSDPGK',
        'frxUSDPKR',   'frxUSDQAR',   'frxUSDRWF',   'frxUSDSAR',   'frxUSDSBD',  'frxUSDSCR',   'frxUSDSDG',   'frxSHPUSD',
        'frxUSDSLL',   'frxUSDSOS',   'frxUSDSRD',   'frxUSDSTD',   'frxUSDSVC',  'frxUSDSZL',   'frxUSDTJS',   'frxUSDTMT',
        'frxUSDTND',   'frxUSDTOP',   'frxUSDTRL',   'frxUSDTRY',   'frxUSDTTD',  'frxUSDTWD',   'frxUSDTZS',   'frxUSDUAH',
        'frxUSDUGX',   'frxUSDUYU',   'frxUSDUZS',   'frxUSDVEB',   'frxUSDVND',  'frxUSDWST',   'frxUSDXAF',   'frxUSDXCD',
        'frxUSDXOF',   'frxUSDXPF',   'frxUSDYER',   'frxUSDYUM',   'frxUSDZMK',  'frxUSDZWD',   'WLDUSD',      'WLDAUD',
        'WLDEUR',      'WLDGBP',      'WLDXAU',      'ADSMI',       'ISEQ',       'CL_BRENT',    'WTI_OIL',     'cryXRPUSDmf',
        'JCI',         'DFMGI',       'SASEIDX',     'EGX30',       'cryBTCUSD',  'cryETHUSD',   'cryLTCUSD',   'cryBCHUSD',
        'cryBUSDUSD',  'cryDAIUSD',   'cryEURSUSD',  'cryIDKUSD',   'cryPAXUSD',  'cryTUSDUSD',  'cryUSDCUSD',  'cryUSDKUSD',
        'cryUSTUSD',   'cryeUSDTUSD', 'cryBNBUSD',   'cryBTCAUD',   'cryBTCBCH',  'cryBTCCAD',   'cryBTCCHF',   'cryBTCETH',
        'cryBTCEUR',   'cryBTCGBP',   'cryBTCJPY',   'cryBTCLTC',   'cryBTCNZD',  'cryBTCRUB',   'cryBTCXAG',   'cryBTCXAU',
        'cryBTCXRP',   'cryDSHUSD',   'cryETHEUR',   'cryIOTUSD',   'cryLTCEUR',  'cryNEOUSD',   'cryOMGUSD',   'cryTRXUSD',
        'cryXMLUSD',   'cryXMRUSD',   'cryXRPEUR',   'cryXRPUSD',   'cryEOSUSD',  'cryZECUSD',   'cryBCHUSDmf', 'cryBTCUSDmf',
        'cryDSHUSDmf', 'cryEOSUSDmf', 'cryETHUSDmf', 'cryLTCUSDmf', 'cryXLMUSD'
    ];
    my $got = [grep { Finance::Underlying->by_symbol($_)->flat_smile } Finance::Underlying->symbols];
    cmp_bag $got, $expected, 'list of flat_smile matches';
};

done_testing();
