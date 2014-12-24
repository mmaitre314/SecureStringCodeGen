using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestPlatform.UnitTestFramework;

namespace UnitTests.Windows
{
    [TestClass]
    public class UnitTests
    {
        [TestMethod]
        public void Windows_TestBasic()
        {
            Assert.AreEqual("value1", GlobalSettings2.Property1); // Key+value in STX
            Assert.AreEqual("value2", GlobalSettings2.Property2); // Key+value in STX
        }
    }
}
