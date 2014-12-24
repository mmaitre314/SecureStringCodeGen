using System;
using Microsoft.VisualStudio.TestPlatform.UnitTestFramework;

namespace UnitTests.WindowsPhone
{
    [TestClass]
    public class UnitTests
    {
        [TestMethod]
        public void WindowsPhone_TestBasic()
        {
            Assert.AreEqual("valueA", GlobalSettings3.Property2); // Key+value in STX with SOX value override
        }
    }
}
