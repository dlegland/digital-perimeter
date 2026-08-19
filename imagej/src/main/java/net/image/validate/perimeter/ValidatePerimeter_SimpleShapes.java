/**
 * 
 */
package net.image.validate.perimeter;

import java.io.IOException;

/**
 * Computes area and perimeter of region on each slice of a stack, for a
 * selection of image shapes (disk, square...).
 */
public class ValidatePerimeter_SimpleShapes
{
    /**
     * @param args
     * @throws IOException 
     */
    public static void main(String[] args) throws IOException
    {
        QuantifyMorphology.pocessSlices("Disk_R50");
        QuantifyMorphology.pocessSlices("Square_S100");
        QuantifyMorphology.pocessSlices("Ellipse_A40_B20");
        QuantifyMorphology.pocessSlices("Lune_R40_D30");
        QuantifyMorphology.pocessSlices("Starfish_40_25");
        QuantifyMorphology.pocessSlices("Trefoil_40_20");
    }
}
