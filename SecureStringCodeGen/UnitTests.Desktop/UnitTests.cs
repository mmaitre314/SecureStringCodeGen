using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UnitTests.Desktop
{
    [TestClass]
    public class UnitTests
    {
        [TestMethod]
        public void Desktop_TestBasic()
        {
            Assert.AreEqual("value1", GlobalSettings.Property1);    // Key+value in STX
            Assert.AreEqual("valueA", GlobalSettings.Property2);    // Key+value in STX with SOX value override
            Assert.AreEqual("valueB", GlobalSettings.Property3);    // Key in STX with SOX value override
            Assert.AreEqual("valueA", GlobalSettings4.Property2);   // Key in STX with SOX value override
        }
    }
}
