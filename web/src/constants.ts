export const GAME_CONTRACT = "0x83930B5AaB9Fd82022De284F016f5C53e4749C9F";
export const TOKEN_CONTRACT = "0xe710FD102Ae9DEFC95137BCB5D227fe945bfc844";
export const CHAIN_ID = 80001;

const MULTICALL2_POLYGON_CONTRACT_ADDRESS =
  process.env.NEXT_PUBLIC_MULTICALL2_POLYGON_CONTRACT_ADDRESS;
const MULTICALL2_MUMBAI_CONTRACT_ADDRESS = "0xcA11bde05977b3631167028862bE2a173976CA11";
const MULTICALL2_WYRM_CONTRACT_ADDRESS = "0x23a327296EB6c4ac98318A702A7Fe1082b922c0b";

export const MULTICALL2_CONTRACT_ADDRESSES = {
  "137": MULTICALL2_POLYGON_CONTRACT_ADDRESS,
  "80001": MULTICALL2_MUMBAI_CONTRACT_ADDRESS,
  "322": MULTICALL2_WYRM_CONTRACT_ADDRESS,
};

export const MAX_INT =
  "115792089237316195423570985008687907853269984665640564039457584007913129639935";

export const AWS_STATIC_ASSETS_PATH = "https://static.simiotics.com/moonstream/assets";

export const FULLCOUNT_ASSETS_PATH = "https://static.simiotics.com/fullcount";
export const DISCORD_LINK = "https://discord.gg/K56VNUQGvA";

export type ChainName = "ethereum" | "localhost" | "mumbai" | "polygon" | "wyrm" | "gnosis";
export type ChainId = 1 | 1337 | 80001 | 137 | 322 | 100;

// map chain names to image paths
const chainNameToImagePath: Record<string, string> = {
  ethereum: `${AWS_STATIC_ASSETS_PATH}/icons/eth-outline.png`,
  localhost: `${AWS_STATIC_ASSETS_PATH}/icons/localhost-outline.png`,
  mumbai: `${AWS_STATIC_ASSETS_PATH}/icons/polygon-outline.png`,
  polygon: `${AWS_STATIC_ASSETS_PATH}/icons/polygon-outline.png`,
  wyrm: `${AWS_STATIC_ASSETS_PATH}/icons/wyrm-small-fill.png`,
  gnosis: `${AWS_STATIC_ASSETS_PATH}/icons/gnosis.png`,
  xdai: `${AWS_STATIC_ASSETS_PATH}/icons/gnosis.png`,
};

// map chain IDs to image paths
const chainIdToImagePath: Record<ChainId, string> = {
  1: `${AWS_STATIC_ASSETS_PATH}/icons/eth-outline.png`,
  1337: `${AWS_STATIC_ASSETS_PATH}/icons/localhost-outline.png`,
  80001: `${AWS_STATIC_ASSETS_PATH}/icons/polygon-outline.png`,
  137: `${AWS_STATIC_ASSETS_PATH}/icons/polygon-outline.png`,
  322: `${AWS_STATIC_ASSETS_PATH}/icons/wyrm-small-fill.png`,
  100: `${AWS_STATIC_ASSETS_PATH}/icons/gnosis.png`,
};

export const getChainImage = (identifier: string | number): string | undefined => {
  if (identifier in chainNameToImagePath) {
    return chainNameToImagePath[identifier as ChainName];
  } else if (identifier in chainIdToImagePath) {
    return chainIdToImagePath[identifier as ChainId];
  }
};
