// import { NativeModules, Platform } from 'react-native';

// const LINKING_ERROR =
//   `The package 'payutesting' doesn't seem to be linked. Make sure: \n\n` +
//   Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
//   '- You rebuilt the app after installing the package\n' +
//   '- You are not using Expo managed workflow\n';

// const Payutesting = NativeModules.Payutesting
//   ? NativeModules.Payutesting
//   : new Proxy(
//       {},
//       {
//         get() {
//           throw new Error(LINKING_ERROR);
//         },
//       }
//     );

// export function multiply(a:any): Promise<any> {
//   return Payutesting.multiply(a);
// }
// export function start(a: any): Promise<any> {
//   return Payutesting.start(a);
// }

import { NativeModules } from 'react-native';
type myType = {
  start(paymentDetails : any): Promise<any>;
  multiply(paymentDetails : any): Promise<any>;
};
const { Payutesting } = NativeModules;
export default Payutesting as myType;