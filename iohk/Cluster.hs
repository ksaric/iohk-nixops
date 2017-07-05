{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UnicodeSyntax #-}
{-# LANGUAGE ViewPatterns #-}

module Cluster where

import qualified Data.Map                      as Map
import           Data.Maybe
import           Data.Monoid
import           Data.String
import           Data.Text                     as T
import           Data.Text.IO                  as T
import           GHC.Generics
import           Network.AWS.Types                (Region(..))


-- * TODO:  currently unused
data ClusterParams
  = ClusterParams
  { cCores      :: Int
  , cCoreRelays :: Int
  , cPureRelays :: Int
  , cWallets    :: Int
  } deriving (Eq, Show)


-- * Domain types
--
-- NOTE: the newtypes are field-less to make the Read/Show prettier
--
newtype CoreId      = CoreId      Integer deriving (Eq, Ord, Read, Show, Num)
newtype CoreRelayId = CoreRelayId Integer deriving (Eq, Ord, Read, Show, Num)
newtype PureRelayId = PureRelayId Integer deriving (Eq, Ord, Read, Show, Num)
newtype WalletId    = WalletId    Integer deriving (Eq, Ord, Read, Show, Num)
fromCoreId      (CoreId      x) = x
fromCoreRelayId (CoreRelayId x) = x
fromPureRelayId (PureRelayId x) = x
fromWalletId    (WalletId    x) = x

data Node
  = Core      Integer Region [CoreId] [CoreRelayId]
  | CoreRelay Integer Region [CoreId] [CoreRelayId] [PureRelayId]
  | PureRelay Integer Region          [CoreRelayId] [PureRelayId]
  | Wallet    Integer                               [PureRelayId]
  deriving (Eq, Read, Show)

nodeId ∷ Node → Integer
nodeId (Core      x _ _ _)   = x
nodeId (CoreRelay x _ _ _ _) = x
nodeId (PureRelay x _ _ _)   = x
nodeId (Wallet    x _)       = x

regionToId ∷ Region → Text
regionToId Frankfurt = "eu-central-1"
regionToId Ireland   = "eu-west-1"
regionToId London    = "eu-west-2"
regionToId Singapore = "ap-southeast-1"
regionToId Sydney    = "ap-southeast-2"
regionToId Tokyo     = "ap-northeast-1"
regionToId Seoul     = "ap-northeast-2"


-- * Domain data
--
-- | A test cluster setup
prettyCluster ∷ [Node]
prettyCluster =             -- core nodes   core relays  pure relays
  [ Core      0  Frankfurt   [ 2, 12 ]    [ 1     ]               -- "eu-central-1"
  , Core      2  Ireland     [ 0,  4 ]    [ 3     ]               -- "eu-west-1"
  , Core      4  London      [ 2,  6 ]    [ 5     ]               -- "eu-west-2"
  , Core      6  Singapore   [ 4,  8 ]    [ 7     ]               -- "ap-southeast-1"
  , Core      8  Sydney      [ 6, 10 ]    [ 9     ]               -- "ap-southeast-2"
  , Core      10 Tokyo       [ 8, 12 ]    [ 11    ]               -- "ap-northeast-1"
  , Core      12 Seoul       [ 10, 0 ]    [ 13    ]               -- "ap-northeast-2"
  , CoreRelay 1  Frankfurt   [ 0     ]    [ 13, 3 ]    [ 14, 15 ]
  , CoreRelay 3  Ireland     [ 2     ]    [ 1,  5 ]    [ 16, 17 ]
  , CoreRelay 5  London      [ 4     ]    [ 3,  7 ]    [ 18, 19 ]
  , CoreRelay 7  Singapore   [ 6     ]    [ 5,  9 ]    [ 20, 21 ]
  , CoreRelay 9  Sydney      [ 8     ]    [ 7, 11 ]    [ 22, 23 ]
  , CoreRelay 11 Tokyo       [ 10    ]    [ 9, 13 ]    [ 24, 25 ]
  , CoreRelay 13 Seoul       [ 12    ]    [ 11, 1 ]    [ 26, 27 ]
  , PureRelay 14 Frankfurt                [ 1     ]    [ 27, 15 ]
  , PureRelay 15 Frankfurt                [ 1     ]    [ 14, 16 ]
  , PureRelay 16 Ireland                  [ 3     ]    [ 15, 17 ]
  , PureRelay 17 Ireland                  [ 3     ]    [ 16, 18 ]
  , PureRelay 18 London                   [ 5     ]    [ 17, 19 ]
  , PureRelay 19 London                   [ 5     ]    [ 18, 20 ]
  , PureRelay 20 Singapore                [ 7     ]    [ 19, 21 ]
  , PureRelay 21 Singapore                [ 7     ]    [ 20, 22 ]
  , PureRelay 22 Sydney                   [ 9     ]    [ 21, 23 ]
  , PureRelay 23 Sydney                   [ 9     ]    [ 22, 24 ]
  , PureRelay 24 Tokyo                    [ 11    ]    [ 23, 25 ]
  , PureRelay 25 Tokyo                    [ 11    ]    [ 24, 26 ]
  , PureRelay 26 Seoul                    [ 13    ]    [ 25, 27 ]
  , PureRelay 27 Seoul                    [ 13    ]    [ 26, 14 ]
  ]

-- | A test cluster setup
currentCluster ∷ [Node]
currentCluster =          -- core nodes   core relays  pure relays
  [ Core      0  Frankfurt   [ 2, 12 ]    [ 1     ]               -- "eu-central-1"
  , Core      2  Ireland     [ 0,  4 ]    [ 3     ]               -- "eu-west-1"
  , Core      4  London      [ 2,  6 ]    [ 5     ]               -- "eu-west-2"
  , Core      6  Singapore   [ 4,  8 ]    [ 7     ]               -- "ap-southeast-1"
  , Core      8  Sydney      [ 6, 10 ]    [ 9     ]               -- "ap-southeast-2"
  , Core      10 Tokyo       [ 8, 12 ]    [ 11    ]               -- "ap-northeast-1"
  , Core      12 Seoul       [ 10, 0 ]    [ 13    ]               -- "ap-northeast-2"
  , CoreRelay 1  Frankfurt   [ 0     ]    [ 13, 3 ]    [ ]
  , CoreRelay 3  Ireland     [ 2     ]    [ 1,  5 ]    [ ]
  , CoreRelay 5  London      [ 4     ]    [ 3,  7 ]    [ ]
  , CoreRelay 7  Singapore   [ 6     ]    [ 5,  9 ]    [ ]
  , CoreRelay 9  Sydney      [ 8     ]    [ 7, 11 ]    [ ]
  , CoreRelay 11 Tokyo       [ 10    ]    [ 9, 13 ]    [ ]
  , CoreRelay 13 Seoul       [ 12    ]    [ 11, 1 ]    [ ]
  ]


-- * Domain → Nix
--
nodeAttrs ∷ Node → NixValue
nodeAttrs (Core      id reg cPeers crPeers) =
  NixAttrSet [ ("i",              NixInt id)
             , ("region",         NixStr $ regionToId reg)
             , ("connectivity",
                NixAttrSet
                [ ("type",           NixStr "core")
                , ("corePeers",      NixList $ NixInt . fromCoreId      <$> cPeers)
                , ("coreRelayPeers", NixList $ NixInt . fromCoreRelayId <$> crPeers)
                ])]
nodeAttrs (CoreRelay id reg cPeers crPeers prPeers) =
  NixAttrSet [ ("i",              NixInt id)
             , ("region",         NixStr $ regionToId reg)
             , ("connectivity",
                NixAttrSet
                [ ("type",           NixStr "core-relay")
                , ("corePeers",      NixList $ NixInt . fromCoreId      <$> cPeers)
                , ("coreRelayPeers", NixList $ NixInt . fromCoreRelayId <$> crPeers)
                , ("pureRelayPeers", NixList $ NixInt . fromPureRelayId <$> prPeers)
                ])]
nodeAttrs (PureRelay id reg        crPeers prPeers) =
  NixAttrSet [ ("i",              NixInt id)
             , ("region",         NixStr $ regionToId reg)
             , ("connectivity",
                NixAttrSet
                [ ("type",           NixStr "pure-relay")
                , ("coreRelayPeers", NixList $ NixInt . fromCoreRelayId <$> crPeers)
                , ("pureRelayPeers", NixList $ NixInt . fromPureRelayId <$> prPeers)
                ])]

emitNixopsSpec ∷ [Node] → Text
emitNixopsSpec = nixEmitTop . NixAttrSet . fmap (\n→ ("node" <> (showT $ nodeId n),
                                                     nodeAttrs n))

writeNixopsSpec ∷ FilePath → [Node] → IO ()
writeNixopsSpec fp = T.writeFile fp . emitNixopsSpec


-- * Nix → text.nix
--
data NixValue
  = NixBool    Bool
  | NixInt     Integer
  | NixStr     Text
  | NixList    [NixValue]
  | NixAttrSet [(Text, NixValue)]
  | NixVar     Text
  deriving (Generic, Show)

showT :: Show a => a -> Text
showT = T.pack . show

nixEmit :: NixValue -> Text
nixEmit (NixBool bool)  = T.toLower $ showT bool
nixEmit (NixInt int)    = showT int
nixEmit (NixStr str)    = "\"" <> str <> "\""
nixEmit (NixList xs)    = ("[ "<>) . (<>" ]")  . intercalate  " " $ nixEmit <$> xs
nixEmit (NixAttrSet xs) = ("{ "<>) . (<>"; }") . intercalate "; " $
                          (\(k,v)→ k <> " = " <> nixEmit v) <$> xs
nixEmit (NixVar name)   = name

nixEmitTop ∷ NixValue → Text
nixEmitTop (NixList    xs) = ("[\n  "<>) . (<>"\n]")  . intercalate  "\n  " $ nixEmit <$> xs
nixEmitTop (NixAttrSet xs) = ("{\n  "<>) . (<>";\n}") . intercalate ";\n  " $
                             (\(k,v)→ k <> " = " <> nixEmit v) <$> xs
nixEmitTop x               = nixEmit x


-- * Domain → text → domain
--
emitConfig ∷ [Node] → Text
emitConfig nodes =
  T.intercalate "\n" $ (T.pack . show) <$> nodes

writeConfig ∷ FilePath → [Node] → IO ()
writeConfig fp = T.writeFile fp . emitConfig

readConfig ∷ FilePath → IO [Node]
readConfig cf = ((read . T.unpack) <$>) . T.lines <$> T.readFile cf
