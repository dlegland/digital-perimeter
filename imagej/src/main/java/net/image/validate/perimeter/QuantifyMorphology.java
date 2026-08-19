/**
 * 
 */
package net.image.validate.perimeter;

import java.io.File;
import java.io.IOException;

import ij.IJ;
import ij.ImageJ;
import ij.ImagePlus;
import ij.ImageStack;
import ij.measure.Calibration;
import ij.measure.Measurements;
import ij.measure.ResultsTable;
import ij.plugin.filter.ParticleAnalyzer;
import ij.process.ImageProcessor;
import ijt.table.Table;
import ijt.table.io.DelimitedTableWriter;
import ijt.table.io.TableWriter;
import inra.ijpb.measure.IntrinsicVolumes2D;

/**
 * 
 */
public class QuantifyMorphology
{
    /**
     * Opens an image stack identified from its base name, computes region
     * morphology (area and perimeter) on each slice of the stack, and saves the
     * result in a table.
     * 
     * @param shapeName
     *            the identification of the shape
     * @throws IOException
     *             an IOException if there is a problem during stack import or
     *             table export
     */
    public static void pocessSlices(String shapeName) throws IOException
    {
        System.out.println("run validation of perimeter on shape: " + shapeName);

        @SuppressWarnings("unused")
        ImageJ imagejInstance = IJ.getInstance();

        File inputDir = new File("../sampleShapes/images");
        
        // check base output Dir
        File outputDir = new File("tables"); 
        if (!outputDir.exists())
        {
            outputDir.mkdir();
        }
        
        // read the stack containing the images
        File imageFile = new File(inputDir, shapeName + "_stack.tif");
        ImagePlus imagePlus = IJ.openImage(imageFile.getPath());
        ImageStack stack = imagePlus.getStack();
        int nSlices = imagePlus.getStackSize();

        // create table for storing results
        String[] colNames = new String[] {"Area", "ImageJ", "Crofton2", "Crofton4"};
        Table resGlobal = Table.create(nSlices, colNames.length);
        resGlobal.setColumnNames(colNames);

        // iterate over images within the stack
        for (int iSlice = 0; iSlice < nSlices; iSlice++)
        {
            ImageProcessor slice = stack.getProcessor(iSlice + 1);
            ImagePlus slicePlus = new ImagePlus("slice" + iSlice, slice);
            IJ.setAutoThreshold(slicePlus, "Otsu dark");

            // compute area, and perimeter using several methods
            ResultsTable resTable = new ResultsTable();
            int measurements = Measurements.AREA | Measurements.PERIMETER; 
            ParticleAnalyzer analyzer = new ParticleAnalyzer(0, measurements, resTable, 0.0, Double.POSITIVE_INFINITY);
            analyzer.analyze(slicePlus);

            double area = resTable.getValue("Area", 0);
            double perimIJ = resTable.getValue("Perim.", 0);
            double perimCrofton2 = IntrinsicVolumes2D.perimeter(slice, new Calibration(), 2);
            double perimCrofton4 = IntrinsicVolumes2D.perimeter(slice, new Calibration(), 4);

            if (iSlice == 0)
            {
                System.out.println("Area = " + area + "  perimeter_IJ = " + perimIJ + "  perimeter_Crofton2 = " + perimCrofton2 + "  perimeter_Crofton4 = " + perimCrofton4);
            }
            resGlobal.setValue(iSlice, 0, area);
            resGlobal.setValue(iSlice, 1, perimIJ);
            resGlobal.setValue(iSlice, 2, perimCrofton2);
            resGlobal.setValue(iSlice, 3, perimCrofton4);
        }

        // Save result table
        File outputFile = new File(outputDir, shapeName + "_morphoImageJ.txt");
        TableWriter writer = new DelimitedTableWriter(outputFile);
        writer.writeTable(resGlobal);
    }
}
